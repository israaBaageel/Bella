import os
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from transformers import CLIPProcessor, CLIPModel
from PIL import Image
from cloudinary.uploader import upload  # This is for Cloudinary upload
import cloudinary

from dotenv import load_dotenv
load_dotenv()


app = Flask(__name__)

# Load the model and processor
model_name = "patrickjohncyh/fashion-clip"
model = CLIPModel.from_pretrained(model_name)
processor = CLIPProcessor.from_pretrained(model_name)

# Define fashion categories and attributes
fashion_categories = ["t-shirt","shirt","blouse","sweater","vest","jacket",
                      "jumpsuit","dress", "jeans", "shorts","pants", "skirt", 
                     "sneakers", "heels","boots", "dress-shoes","sandals",
                       "bag","handbag", "backpack", "purse"]

fashion_attributes = {
    "category": ["top", "shoes", "bottom", "dress","others"],
    "color": ["Red", "Blue", "Yellow", "Green", "Orange", "Purple", "Violet",  
              "Magenta", "White", "Black", "Gray", "Light Gray", "Dark Gray", "Silver",
              "Beige", "Gold", "Amber", "Coral", "Peach", "Rust", "Maroon", "Scarlet", "Turquoise", "Mint",
              "Lavender", "Navy", "Ice Blue", "Baby Pink", "Sky Blue", "Lilac", "Powder Blue", "Pale Yellow",
                "Rose Quartz", "Brown", "Olive Green",  "Khaki", "Bronze", "Copper", "Platinum",
              "Rose Gold", "Neon Green", "Electric Blue", "Hot Pink", "Bright Purple",
             "Burgundy", "Deep Purple", "Cyan", "Fuchsia", "floral"],

    "style": ["casual", "formal", "sporty", "bohemian"],
    "season": ["summer", "winter", "spring", "fall"],
    "sleeve_length": ["long sleeve", "short sleeve", "sleeveless", "no sleeves"],
    "bag_type": ["tote bag", "clutch", "backpack", "shoulder bag", "no bag"]
}

# Cloudinary credentials (make sure you have set these in your environment variables or .env file)
cloudinary.config(
  cloud_name=os.getenv('CLOUDINARY_CLOUD_NAME'),
  api_key=os.getenv('CLOUDINARY_API_KEY'),
  api_secret=os.getenv('CLOUDINARY_SECRET_KEY')
)

# Helper function to analyze clothing
# Analyze clothing
def analyze_clothing(image_path):
    image = Image.open(image_path)

    # Predict clothing type
    inputs = processor(text=fashion_categories, images=image, return_tensors="pt", padding=True)
    outputs = model(**inputs)
    probs = outputs.logits_per_image.softmax(dim=1)
    clothing_type = fashion_categories[probs.argmax().item()]

    # Map type to category
    type_to_category = {
        "t-shirt": "top",
        "shirt": "top",
        "sweater": "top",
        "blouse": "top",
        "jacket": "top",
        "vest": "top",
        "dress": "dress",
        "jeans": "bottom",
        "pants": "bottom",
        "shorts": "bottom",
        "skirt": "bottom",
        "sneakers": "shoes",
        "heels": "shoes",
        "dress-shoes": "shoes",
        "boots": "shoes",
        "sandals": "shoes",
        "bag": "others",
        "handbag": "others",
        "backpack": "others",
        "purse": "others",
    }

    attributes = {
        "type": clothing_type,
        "category": type_to_category.get(clothing_type, "others")
    }

    # Predict other attributes
    for attr, options in fashion_attributes.items():
        if attr == "category":  # Already handled
            continue
        if attr == "sleeve_length" and clothing_type in ["bag", "handbag", "backpack", "purse", "sneakers", "heels"]:
            continue
        if attr == "bag_type" and clothing_type not in ["bag", "handbag", "backpack", "purse"]:
            continue

        inputs = processor(text=options, images=image, return_tensors="pt", padding=True)
        outputs = model(**inputs)
        probs = outputs.logits_per_image.softmax(dim=1)
        attributes[attr] = options[probs.argmax().item()]

    return attributes

# Function to generate outfit based on the analysis
def generate_outfit(analysis):
    outfit_rules = {
        "t-shirt": {
            "bottom": "jeans" if analysis["style"] == "casual" else "chinos",
            "shoes": "sneakers" if analysis["style"] == "casual" else "loafers"
        },
        "dress": {
            "shoes": "heels" if analysis["style"] == "formal" else "sandals",
            "accessories": ["clutch"] if analysis["style"] == "formal" else ["tote bag"]
        },
        "jeans": {
            "top": "blouse" if analysis["style"] == "formal" else "t-shirt",
            "shoes": "loafers" if analysis["style"] == "formal" else "sneakers"
        },
        "heels": {
            "outfit_pairing": "Pair with a formal dress or skirt" if analysis["style"] == "formal" else "Can work with dressy jeans"
        }
    }

    base_outfit = {"main": f"{analysis['color']} {analysis['type']}"}
    return {**base_outfit, **outfit_rules.get(analysis["type"], {})}

@app.route('/predict', methods=['POST'])
def predict():
    # Check if an image was uploaded
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400
    
    # Get the image file
    image_file = request.files['image']
    
    # Save image to a temporary file
    filename = secure_filename(image_file.filename)
    image_path = os.path.join('uploads', filename)
    image_file.save(image_path)

    try:
        # Analyze the image to classify clothing and get attributes
        analysis = analyze_clothing(image_path)
        
        # Generate outfit suggestion based on the analysis
        outfit = generate_outfit(analysis)
        
        # Upload image and analysis to Cloudinary
        image_url = upload_to_cloudinary(image_path, analysis)
        
        # Return the analysis, outfit suggestion, and image URL as a response
        return jsonify({'analysis': analysis, 'outfit': outfit, 'image_url': image_url})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def upload_to_cloudinary(image_path, analysis):
    # Upload image to Cloudinary
    response = upload(
        image_path,
        public_id=secure_filename(image_path),
        tags=[str(val) for val in analysis.values()]  # Add tags as metadata
    )
    
    if response.get('secure_url'):
        return response['secure_url']
    else:
        raise Exception("Cloudinary upload failed.")

if __name__ == '__main__':
    app.run(debug=True)

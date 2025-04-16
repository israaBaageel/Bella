import os
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from transformers import CLIPProcessor, CLIPModel
from PIL import Image
from cloudinary.uploader import upload  # This is for Cloudinary upload
import cloudinary

app = Flask(__name__)

# Load the model and processor
model_name = "patrickjohncyh/fashion-clip"
model = CLIPModel.from_pretrained(model_name)
processor = CLIPProcessor.from_pretrained(model_name)

# Define fashion categories and attributes
fashion_categories = ["t-shirt", "dress", "jeans", "jacket", "shorts",
                     "skirt", "blouse", "sneakers", "heels", "bag",
                     "handbag", "backpack", "purse", "dress-shoes"]

fashion_attributes = {
    "category": ["top", "shoes", "bottom", "dress","others"],
    "color": ["Red", "Blue", "Yellow", "Green", "Orange", "Purple", "Violet", "Red-Orange", "Yellow-Orange", "Yellow-Green", "Blue-Green", 
              "Teal", "Blue-Purple", "Indigo", "Red-Purple", "Magenta", "White", "Black", "Gray", "Light Gray", "Dark Gray", "Silver",
              "Beige", "Ivory", "Taupe", "Charcoal", "Gold", "Amber", "Coral", "Peach", "Rust", "Maroon", "Scarlet", "Turquoise", "Mint",
              "Lavender", "Slate", "Navy", "Ice Blue", "Baby Pink", "Sky Blue", "Lilac", "Powder Blue", "Pale Yellow", "Rose Quartz", "Brown",
              "Tan", "Olive Green", "Terracotta", "Khaki", "Sand", "Sienna", "Umber", "Ochre", "Moss Green", "Bronze", "Copper", "Platinum",
              "Rose Gold", "Gunmetal", "Neon Green", "Electric Blue", "Hot Pink", "Bright Purple", "Lemon Yellow", "Fluorescent Orange",
              "Midnight Blue", "Ebony", "Burgundy", "Forest Green", "Deep Purple", "Dark Slate", "Cyan", "Fuchsia", "Chartreuse", "Vermillion",
              "Mauve", "Cerulean", "Salmon", "floral"],
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
def analyze_clothing(image_path):
    image = Image.open(image_path)

    # Classify clothing type
    inputs = processor(text=fashion_categories, images=image, return_tensors="pt", padding=True)
    outputs = model(**inputs)
    probs = outputs.logits_per_image.softmax(dim=1)
    clothing_type = fashion_categories[probs.argmax().item()]

    # Detect attributes
    attributes = {}
    for attr, options in fashion_attributes.items():
        if attr == "sleeve_length" and clothing_type in ["bag", "handbag", "backpack", "purse", "sneakers", "heels"]:
            continue
        if attr == "bag_type" and clothing_type not in ["bag", "handbag", "backpack", "purse"]:
            continue

        inputs = processor(text=options, images=image, return_tensors="pt", padding=True)
        outputs = model(**inputs)
        probs = outputs.logits_per_image.softmax(dim=1)
        attributes[attr] = options[probs.argmax().item()]

    return {"type": clothing_type, **attributes}

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

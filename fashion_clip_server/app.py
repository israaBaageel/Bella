import os
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from transformers import CLIPProcessor, CLIPModel
from PIL import Image
from cloudinary.uploader import upload
import cloudinary
import random
from firebase_admin import credentials, firestore, initialize_app
from dotenv import load_dotenv
from google.cloud.firestore_v1.base_query import FieldFilter
load_dotenv()
import random
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
firebase_key_path = os.path.join(BASE_DIR, "firebase-key.json")
cred = credentials.Certificate(firebase_key_path)

# Initialize Firebase
#cred = credentials.Certificate("firebase-key.json")
initialize_app(cred)
db = firestore.client()

# Initialize Flask
app = Flask(__name__)

# Load the FashionCLIP model
model_name = "patrickjohncyh/fashion-clip"
model = CLIPModel.from_pretrained(model_name)
processor = CLIPProcessor.from_pretrained(model_name)

# Define fashion categories and attributes
fashion_categories = [
    "t-shirt", "shirt", "blouse", "sweater", "vest", "jacket",
    "jumpsuit", "dress", "jeans", "shorts", "pants", "skirt",
    "sneakers", "heels", "boots", "dress-shoes", "sandals",
    "bag", "handbag", "backpack", "purse"
]

fashion_attributes = {
    "category": ["top", "shoes", "bottom", "dress", "others"],
    "color": ["Red", "Blue", "Yellow", "Green", "Orange", "Purple", "Violet",  
              "Magenta", "White", "Black", "Gray", "Light Gray", "Dark Gray", "Silver",
              "Beige", "Gold", "Amber", "Coral", "Peach", "Rust", "Maroon", "Scarlet", "Turquoise", "Mint",
              "Lavender", "Navy", "Ice Blue", "Baby Pink", "Sky Blue", "Lilac", "Powder Blue", "Pale Yellow",
              "Rose Quartz", "Brown", "Olive Green", "Khaki", "Bronze", "Copper", "Platinum",
              "Rose Gold", "Neon Green", "Electric Blue", "Hot Pink", "Bright Purple",
              "Burgundy", "Deep Purple", "Cyan", "Fuchsia", "floral"],
    "style": ["casual", "formal", "sporty", "bohemian"],
    "season": ["summer", "winter", "spring", "fall"],
    "sleeve_length": ["long sleeve", "short sleeve", "sleeveless", "no sleeves"],
    "bag_type": ["tote bag", "clutch", "backpack", "shoulder bag", "no bag"]
}

# Cloudinary config
cloudinary.config(
    cloud_name=os.getenv('CLOUDINARY_CLOUD_NAME'),
    api_key=os.getenv('CLOUDINARY_API_KEY'),
    api_secret=os.getenv('CLOUDINARY_SECRET_KEY')
)

# Helper: Analyze clothing
def analyze_clothing(image_path):
    image = Image.open(image_path)

    inputs = processor(text=fashion_categories, images=image, return_tensors="pt", padding=True)
    outputs = model(**inputs)
    probs = outputs.logits_per_image.softmax(dim=1)
    clothing_type = fashion_categories[probs.argmax().item()]

    type_to_category = {
        "t-shirt": "top", "shirt": "top", "sweater": "top", "blouse": "top", "jacket": "top", "vest": "top",
        "dress": "dress", "jumpsuit": "dress",
        "jeans": "bottom", "pants": "bottom", "shorts": "bottom", "skirt": "bottom",
        "sneakers": "shoes", "heels": "shoes", "dress-shoes": "shoes", "boots": "shoes", "sandals": "shoes",
        "bag": "others", "handbag": "others", "backpack": "others", "purse": "others"
    }

    attributes = {
        "type": clothing_type,
        "category": type_to_category.get(clothing_type, "others")
    }

    for attr, options in fashion_attributes.items():
        if attr == "category":
            continue
        if attr == "sleeve_length" and attributes["category"] not in ["top", "dress"]:
            continue
        if attr == "bag_type" and attributes["category"] != "others":
            continue

        inputs = processor(text=options, images=image, return_tensors="pt", padding=True)
        outputs = model(**inputs)
        probs = outputs.logits_per_image.softmax(dim=1)
        attributes[attr] = options[probs.argmax().item()]

    return attributes

# Upload to Cloudinary
def upload_to_cloudinary(image_path, analysis):
    response = upload(
        image_path,
        public_id=secure_filename(image_path),
        tags=[str(val) for val in analysis.values()]
    )
    if response.get('secure_url'):
        return response['secure_url']
    else:
        raise Exception("Cloudinary upload failed.")

# to upload and predict the clothing items
@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    # to get the user id and make the predection based on each user 
    uid = request.form.get('uid')
    if not uid:
        return jsonify({"error": "No UID provided"}), 400

    image_file = request.files['image']
    filename = secure_filename(image_file.filename)
    image_path = os.path.join('uploads', filename)
    image_file.save(image_path)

    try:
        analysis = analyze_clothing(image_path)
        image_url = upload_to_cloudinary(image_path, analysis)

        #  Save under users > uid > clothingItems
        db.collection('users').document(uid).collection('clothingItems').add({
            "url": image_url,
            "uid": uid, #new to help with the donation So when we donate, we know which user owns the item
            **analysis
        })

        return jsonify({
            'analysis': analysis,
            'url': image_url
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

#  Generate full outfit


# Generate full outfit
@app.route("/generate-outfit", methods=["GET"])
def generate_outfit():
    import random

    uid = request.args.get('uid')
    style = request.args.get('style', '')

    if not uid:
        return jsonify({"error": "Missing user ID"}), 400

    try:
        # Fetch items only for this user
        docs = db.collection('users').document(uid).collection('clothingItems').stream()
        items = [doc.to_dict() for doc in docs]

        if not items:
            return jsonify({"error": "No clothing items found for user."}), 400

        # Filter by style if specified
        filtered_items = [item for item in items if item.get('style') == style] if style else items

        if not filtered_items:
            return jsonify({"error": "No clothing items match the selected style."}), 400

        tops = [item for item in filtered_items if item.get('category') == 'top']
        bottoms = [item for item in filtered_items if item.get('category') == 'bottom']
        dresses = [item for item in filtered_items if item.get('category') == 'dress']
        shoes = [item for item in filtered_items if item.get('category') == 'shoes']

        outfit = {}

        if dresses and shoes and (not tops or not bottoms or random.choice([True, False])):
            outfit["dress"] = random.choice(dresses)
            outfit["shoes"] = random.choice(shoes) if shoes else None
        elif tops and bottoms and shoes:
            outfit["top"] = random.choice(tops)
            outfit["bottom"] = random.choice(bottoms)
            outfit["shoes"] = random.choice(shoes)
        else:
            return jsonify({"error": "Not enough items to generate a complete outfit."}), 400

        return jsonify({"outfit": outfit})

    except Exception as e:
        print("Error generating outfit:", str(e))
        return jsonify({"error": str(e)}), 500







# Run the app
if __name__ == '__main__':
    app.run(debug=True)

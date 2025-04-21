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

load_dotenv()

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

# Endpoint: Upload & Predict
@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    image_file = request.files['image']
    filename = secure_filename(image_file.filename)
    image_path = os.path.join('uploads', filename)
    image_file.save(image_path)

    try:
        analysis = analyze_clothing(image_path)
        image_url = upload_to_cloudinary(image_path, analysis)

        # Save to Firestore
        db.collection('clothingItems').add({
            "url": image_url,
            **analysis
        })

        return jsonify({
            'analysis': analysis,
            'url': image_url
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ✅ NEW: Generate full outfit
@app.route('/generate-outfit', methods=['GET'])
def generate_outfit():
    clothing_ref = db.collection('clothingItems')
    docs = clothing_ref.stream()
    items = [doc.to_dict() for doc in docs]

    tops = [item for item in items if item.get('type') in ['t-shirt', 'shirt', 'blouse', 'sweater', 'jacket', 'vest']]
    bottoms = [item for item in items if item.get('type') in ['jeans', 'pants', 'shorts', 'skirt']]
    dresses = [item for item in items if item.get('type') in ['dress', 'jumpsuit']]
    shoes = [item for item in items if item.get('type') in ['sneakers', 'heels', 'dress-shoes', 'boots', 'sandals']]

    outfit = {}

    # ✅ Randomly decide to generate top+bottom or dress
    if (tops and bottoms) and dresses:
        choice = random.choice(['top_bottom', 'dress'])
    elif tops and bottoms:
        choice = 'top_bottom'
    elif dresses:
        choice = 'dress'
    else:
        return jsonify({'message': 'Not enough clothing items'}), 200

    if choice == 'top_bottom':
        outfit['top'] = random.choice(tops)
        outfit['bottom'] = random.choice(bottoms)
    elif choice == 'dress':
        outfit['dress'] = random.choice(dresses)

    if shoes:
        outfit['shoes'] = random.choice(shoes)

    return jsonify({'outfit': outfit})


# Run the app
if __name__ == '__main__':
    app.run(debug=True)

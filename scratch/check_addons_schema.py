import requests
import json

def check_addons(url):
    r = requests.get(url, headers={"Accept": "application/json", "app": "user"}, timeout=10)
    data = r.json()
    products = data.get("products", []) if isinstance(data, dict) else data
    with_addons = [p for p in products if p.get("addons") or p.get("modifierGroups") or p.get("modifiers") or p.get("discounts")]
    print(f"Products with addons/discounts: {len(with_addons)}")
    for p in with_addons:
        print(f"Product: {p.get('name')}")
        if p.get('addons'):
            print("  addons:", json.dumps(p.get('addons'), indent=2))
        if p.get('discounts'):
            print("  discounts:", json.dumps(p.get('discounts'), indent=2))
        if p.get('modifierGroups'):
            print("  modifierGroups:", json.dumps(p.get('modifierGroups'), indent=2))
        if p.get('modifiers'):
            print("  modifiers:", json.dumps(p.get('modifiers'), indent=2))

print("=== BETA ===")
check_addons("https://api.beta.order.rebuzzpos.com/api/businesses/6a8a87631d9c3a6661f3bb12/products")
print("=== PROD ===")
check_addons("https://api.order.rebuzzpos.com/api/businesses/65db0f54d0199c9b3dc7ab15/products")

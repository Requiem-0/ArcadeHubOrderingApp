import requests
import json

def check(url, name):
    print(f"=== {name}: {url} ===")
    try:
        r = requests.get(url, headers={"Accept": "application/json", "app": "user"}, timeout=10)
        print("Status:", r.status_code)
        if r.status_code == 200:
            data = r.json()
            products = data.get("products", []) if isinstance(data, dict) else data
            print(f"Found {len(products)} products")
            if products:
                # inspect first 3 products with all keys
                for p in products[:3]:
                    print("--- Product ---")
                    print(json.dumps(p, indent=2))
        else:
            print("Response:", r.text[:300])
    except Exception as e:
        print("Error:", e)

check("https://api.beta.order.rebuzzpos.com/api/businesses/6a8a87631d9c3a6661f3bb12/products", "BETA")
check("https://api.order.rebuzzpos.com/api/businesses/65db0f54d0199c9b3dc7ab15/products", "PROD")

import csv
import random
import re
import os
import zipfile

# --- FIELD CONFIGURATION ---
CAMPO_PREGUNTA = 'Question__c' 
CAMPO_RESPUESTA = 'Answer__c'

# Set up paths and directories
base_path = os.path.dirname(os.path.abspath(__file__))
output_dir = os.path.join(base_path, "sfdc_package")
data_dir = os.path.join(output_dir, "data")

# Create data directory if it doesn't exist
if not os.path.exists(data_dir):
    os.makedirs(data_dir)

CSV_PATH = os.path.join(output_dir, 'import.csv')
PROPS_PATH = os.path.join(output_dir, 'knowledge.properties')
ZIP_PATH = os.path.join(base_path, 'upload_to_salesforce.zip')

# Sample data for article generation
issues = ["Generator failure after surge", "Rotor assembly vibration", "Circuit malfunctioning"]
solutions = ["Check wiring connections.", "Replace sensors.", "Reset bypass sequence."]

def slugify(text):
    """Converts text into a URL-friendly slug"""
    return re.sub(r'\W+', '-', text.lower()).strip('-')

def create_package():
    print(f"[*] Generating articles (HTML for Question and Answer)...")
    
    # 1. GENERATE CSV AND HTML FILES
    with open(CSV_PATH, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        # Define CSV headers
        writer.writerow(['Title', 'Summary', 'URLName', 'channels', CAMPO_PREGUNTA, CAMPO_RESPUESTA])

        for i in range(1, 501):
            issue = random.choice(issues)
            title = f"Guide {i}: {issue}"
            url_name = slugify(f"guide-{issue}-{i}")
            
            # Create HTML file for the QUESTION field
            q_filename = f"q_{i}.html"
            with open(os.path.join(data_dir, q_filename), 'w', encoding='utf-8') as f:
                f.write(f"<html><body>{issue}</body></html>")
            
            # Create HTML file for the ANSWER field
            a_filename = f"a_{i}.html"
            with open(os.path.join(data_dir, a_filename), 'w', encoding='utf-8') as f:
                f.write(f"<html><body><p>{random.choice(solutions)}</p></body></html>")
            
            # Write CSV row pointing to the relative paths of the HTML files
            writer.writerow([title, title, url_name, 'application', f"data/{q_filename}", f"data/{a_filename}"])

    # 2. GENERATE PROPERTIES FILE (Standard Salesforce Knowledge Import format)
    print(f"[*] Writing knowledge.properties...")
    with open(PROPS_PATH, 'w', encoding='utf-8') as f:
        f.write("CSVEncoding=UTF8\n")
        f.write("RTAEncoding=UTF8\n")
        f.write("CSVSeparator=,\n")
        f.write("#DateFormat=yyyy-MM-dd")

    # 3. CREATE THE ZIP PACKAGE
    print(f"[*] Compressing into {ZIP_PATH}...")
    try:
        # Remove existing ZIP file if it exists to avoid conflicts
        if os.path.exists(ZIP_PATH):
            os.remove(ZIP_PATH)
            
        with zipfile.ZipFile(ZIP_PATH, 'w', zipfile.ZIP_DEFLATED) as zipf:
            # Add main control files to the root of the ZIP
            zipf.write(CSV_PATH, arcname='import.csv')
            zipf.write(PROPS_PATH, arcname='knowledge.properties')
            
            # Add all individual HTML files from the data folder
            for root, dirs, files in os.walk(data_dir):
                for f in files:
                    file_full_path = os.path.join(root, f)
                    zipf.write(file_full_path, arcname=os.path.join("data", f))
        
        print(f"\n[SUCCESS] You can now upload 'upload_to_salesforce.zip' to Salesforce.")
    except Exception as e:
        print(f"\n[ERROR]: {e}")

if __name__ == "__main__":
    create_package()
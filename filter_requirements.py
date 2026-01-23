import sys
import pkg_resources

def filter_requirements(input_path, output_path):
    # 1. Get list of currently installed system packages (ROS, Apt, etc.)
    #    We convert to lowercase for case-insensitive comparison
    installed_packages = {pkg.key.lower() for pkg in pkg_resources.working_set}

    with open(input_path, 'r') as f_in, open(output_path, 'w') as f_out:
        print(f"Filtering {input_path} -> {output_path}...")
        
        for line in f_in:
            line = line.strip()
            
            # Skip empty lines, comments, and local file paths (@ file://)
            if not line or line.startswith('#') or line.startswith('@'):
                continue
            
            # Parse package name (handle "package==version" or just "package")
            # We split by common operators to get the clean name
            pkg_name_raw = line.split('==')[0].split('>=')[0].split('<=')[0].split('~=')[0]
            pkg_name = pkg_name_raw.strip().lower()

            # CHECK: Is it already installed via ROS/System?
            if pkg_name in installed_packages:
                print(f"  [SKIP] System/ROS Package: {pkg_name}")
                continue

            # If it passes checks, keep it
            f_out.write(line + '\n')
            
        print("Filtering complete.")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python filter_requirements.py <input_file> <output_file>")
        sys.exit(1)
    
    filter_requirements(sys.argv[1], sys.argv[2])

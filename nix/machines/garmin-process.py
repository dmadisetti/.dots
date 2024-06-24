import time
from garmin_fit_sdk import Decoder, Stream
import sys
import os


def list_files(path):
    with os.scandir(path) as entries:
        for entry in entries:
            print(entry.name)


# Use the function
list_files('/media/garmin/GARMIN')

# Print command-line arguments
print("Command-line arguments:")
for arg in sys.argv:
    print(arg)

# Print environment variables
print("\nEnvironment variables:")
for key, value in os.environ.items():
    print(f"{key}: {value}")

time.sleep(60)  # Sleep for 60 seconds
print(Decoder, Stream)

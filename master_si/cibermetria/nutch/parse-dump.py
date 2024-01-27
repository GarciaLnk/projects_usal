import re
import csv
from urllib.parse import urlparse, urlunparse

file_path = "dump"


# Function to normalize URL
def normalize_url(url):
    parsed_url = urlparse(url)

    # Convert scheme to https
    scheme = "https"

    # Add 'www' as subdomain if not present
    netloc = parsed_url.netloc
    if not netloc.startswith("www."):
        netloc = "www." + netloc

    normalized_url = urlunparse(
        (
            scheme,
            netloc,
            parsed_url.path,
            parsed_url.params,
            parsed_url.query,
            parsed_url.fragment,
        )
    )

    return normalized_url


# Function to parse the Nutch dump
def parse_nutch_dump(file_path):
    with open(file_path, "r") as file:
        dump_data = file.read()

    # Split the data into records
    records = dump_data.split("Recno::")
    records = [record.strip() for record in records if record.strip()]

    url_outlinks = {}

    # Regex patterns
    url_pattern = re.compile(r"URL:: (.+)")
    outlink_pattern = re.compile(r"outlink: toUrl: (.+) anchor:")

    for record in records:
        url_match = url_pattern.search(record)
        if url_match:
            url = normalize_url(url_match.group(1).strip())
            url_outlinks[url] = set()

            # Extract outlinks
            outlinks = set(outlink_pattern.findall(record))
            for outlink in outlinks:
                normalized_outlink = normalize_url(outlink.strip())
                # Use add method for set to ignore duplicates
                url_outlinks[url].add(normalized_outlink)
    # Convert sets back to lists
    url_outlinks = {url: list(outlinks) for url, outlinks in url_outlinks.items()}

    return url_outlinks


# Generate an edge list for the network
def generate_edge_list(data):
    edge_list = []
    for url, outlinks in data.items():
        for outlink in outlinks:
            edge_list.append((url, outlink))
    return edge_list


# Parse the file
parsed_data = parse_nutch_dump(file_path)
edge_list = generate_edge_list(parsed_data)
edge_list_file_path = "dump_edge_list.csv"

# Write the edge list to a CSV file
with open(edge_list_file_path, mode="w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    writer.writerow(["Source", "Target"])
    for edge in edge_list:
        writer.writerow(edge)

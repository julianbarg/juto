#!/usr/bin/env python3
# Based on https://github.com/Jmuccigr/scripts/blob/master/remove_PDF_text.py

import sys
import argparse
from pypdf import PdfWriter, PdfReader

def remove_text_from_pdf(input_filename, output_filename):
    output = PdfWriter()
    ipdf = PdfReader(open(input_filename, 'rb'))

    for i in range(len(ipdf.pages)):
        page = ipdf.pages[i]
        output.add_page(page)

    output.remove_text()

    with open(output_filename, 'wb') as f:
       output.write(f)

def main():
    parser = argparse.ArgumentParser(description='Remove text layer from PDF.')
    parser.add_argument('input_filename', help='The input PDF file.')
    parser.add_argument('output_filename', help='The output PDF file.')

    args = parser.parse_args()

    remove_text_from_pdf(args.input_filename, args.output_filename)

if __name__ == '__main__':
    main()


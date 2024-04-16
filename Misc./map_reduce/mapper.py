#!/usr/bin/env python3
import sys

def mapper():
    """
    Reads in a sentence and maps the values
    """
    # stdin = standard input
    for line in sys.stdin:

        # Strip white space at the beginning and end of line
        line = line.strip()

        # Split the line into the words
        words = line.split()

        # Process each words and assign a value of 1 to each words
        for word in words:
            print(word + '\t1')

if __name__ == '__main__':
    mapper()
#!usr/bin/env python3
import sys

def reducer_mapped():
    """
    Reduce mapped values
    """
    current_word = None
    current_count = 0
    
    # Loop through lines passed in from mapper.py program

    for line in sys.stdin:
        line = line.strip()
        word, count = line.split('\t1', 1)
        
        count = int(count)

        if current_count == word:
            current_count += count

        else:
            # If there IS a current word and it's not "None"
            if current_word:
                print(current_word + '\t' + str(current_count))
            current_count = count
            current_word = word

    if current_word == word:
        print(current_word + '\t' + str(current_count))

if __name__ == "__main__":
    mapper()
#!/usr/bin/env python2
import os
import subprocess
import sys


def main(target, output):
    args = [
        'bulk_extractor', target, '-o', output,
        '-M', '250', '-q', '-1',
        # disables all
        '-x', 'all',
        # compressed data processing
        '-e', 'gzip', '-e', 'base64', '-e', 'hiberfile', '-e', 'pdf', '-e', 'zip', '-e', 'rar',
        # numeric accounts, such as phone numbers and ccns
        '-e', 'accts'
    ]
    try:
        os.makedirs(output)
        subprocess.call(args)
        # remove empty BulkExtractor logs
        for filename in os.listdir(output):
            filepath = os.path.join(output, filename)
            if os.path.getsize(filepath) == 0:
                os.remove(filepath)
        return 0
    except Exception as e:
        return e


if __name__ == '__main__':
    target = sys.argv[1]
    sipdir = sys.argv[2]
    file_uuid = sys.argv[3]
    output = os.path.join(sipdir, 'logs', 'bulk-' + file_uuid)
    sys.exit(main(target, output))

`gem install oj`

## Strategy

1) Read in the data files with a streaming JSON parser and write each JSON blob as a single indexed line in a .db file
2) Maintain multiple in-memory indexes of ids/etc to byte offsets (can write to file for backup)
3) For indexed searches, just look up the index
4) For unindexed searches, scan through the file doing a raw string match for the value. Only parse and check for rows that match the value

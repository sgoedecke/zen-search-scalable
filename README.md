# zen-search-scalable

An attempt at a "properly-scalable" Ruby implementation of the Zendesk search challenge

## Usage

`gem install oj`
`ruby ./src/main.rb`

## But does it work?

To ensure it is actually scalable, run it in a tight space:
`ulimit -v ???`

## Strategy

1) Maintain a file db with an in-memory index of values to byte offsets in the heap file
1) Read in the data files with a streaming JSON parser and write each JSON blob as a single record in our indexed db
3) For indexed searches, just look up the index
4) For unindexed searches, scan through the file doing a raw string match for the value. Only parse and check for rows that match the value

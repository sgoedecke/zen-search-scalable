# zen-search-scalable

An attempt at a "properly-scalable" Ruby implementation of the Zendesk search challenge

## Usage

`gem install oj && ruby ./src/main.rb`

## Tradeoffs

My entire implementation (see Strategy below) was aimed at reducing the memory footprint of the app once running. I accepted a potentially-slower startup time as a consequence of this (I haven't measured, but it eyeballs as maybe a fraction slower than the naive version). It'd be trivial to support writing out an index to file though, in which case all startups after the first would be effectively instant.

I've only indexed on `_id` for the same reason: making searches slower but the memory footprint smaller. I would have left the indexes off entirely if the data was not relational, but since each query will fan out to fetch the related records it's worth optimizing those secondary fetches.

Although not a requirement, an advantage of this approach is that it would be easy to add more data while the program is still running.

## But does it work?

I've used https://github.com/SamSaffron/memory_profiler to profile the memory usage of this app against a naive in-memory data store implementation (see `src/db/naive`). With around 60MB of source data, the in-memory data store held onto 723MB of memory:
```
Total allocated: 1.37 GB (2400034 objects)
Total retained:  723.07 MB (1500010 objects)
```

My file-based data store held onto under 25MB of memory, by comparison (almost all in the indexes):
```
Total allocated: 2.19 GB (6300064 objects)
Total retained:  24.61 MB (300025 objects)
```

I generated large files to test against with the script in `test/generate_large_file.rb`.

## Strategy

1) Maintain a file db with an in-memory index of values to byte offsets in the heap file
1) Read in the data files with a streaming JSON parser and write each JSON blob as a single record in our indexed db
3) For indexed searches, just look up the index
4) For unindexed searches, scan through the file doing a raw string match for the value. Only parse and check for rows that match the value


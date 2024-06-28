---
description: The search index APIs
linkTitle: Search index
title: Search index
type: integration
weight: 3
---

| Class            | Description                                                                                  |
| ---------------- | -------------------------------------------------------------------------------------------- |
| SearchIndex      | Primary class to write, read, and search across data structures in Redis.                    |
| AsyncSearchIndex | Async version of the SearchIndex to write, read, and search across data structures in Redis. |

## SearchIndex

<a id="searchindex-api"></a>

### _class_ SearchIndex(schema, redis_client=None, redis_url=None, connection_args={}, \*\*kwargs)

A search index class for interacting with Redis as a vector database.

The SearchIndex is instantiated with a reference to a Redis database and an
IndexSchema (YAML path or dictionary object) that describes the various
settings and field configurations.

```python
from redisvl.index import SearchIndex

# initialize the index object with schema from file
index = SearchIndex.from_yaml("schemas/schema.yaml")
index.connect(redis_url="redis://localhost:6379")

# create the index
index.create(overwrite=True)

# data is an iterable of dictionaries
index.load(data)

# delete index and data
index.delete(drop=True)
```

Initialize the RedisVL search index with a schema, Redis client
(or URL string with other connection args), connection_args, and other
kwargs.

- **Parameters:**
  - **schema** ([_IndexSchema_](schema.md#redisvl.schema.IndexSchema)) – Index schema object.
  - **redis_client** (_Union_ _[\*\*redis.Redis_ _,_ _aredis.Redis_ _]_ _,_ _optional_) – An
    instantiated redis client.
  - **redis_url** (_str_ _,_ _optional_) – The URL of the Redis server to
    connect to.
  - **connection_args** (_Dict_ _[\*\*str_ _,_ _Any_ _]_ _,_ _optional_) – Redis client connection
    args.

### connect(redis_url=None, \*\*kwargs)

Connect to a Redis instance using the provided redis_url, falling
back to the PHARMAVILLAGE_URL environment variable (if available).

Note: Additional keyword arguments (\*\*kwargs) can be used to provide
extra options specific to the Redis connection.

- **Parameters:**
  **redis_url** (_Optional_ _[\*\*str_ _]_ _,_ _optional_) – The URL of the Redis server to
  connect to. If not provided, the method defaults to using the
  PHARMAVILLAGE_URL environment variable.
- **Raises:**
  - **redis.exceptions.ConnectionError** – If the connection to the Redis
    server fails.
  - **ValueError** – If the Redis URL is not provided nor accessible
    through the PHARMAVILLAGE_URL environment variable.

```python
index.connect(redis_url="redis://localhost:6379")
```

### create(overwrite=False, drop=False)

Create an index in Redis with the current schema and properties.

- **Parameters:**
  - **overwrite** (_bool_ _,_ _optional_) – Whether to overwrite the index if it
    already exists. Defaults to False.
  - **drop** (_bool_ _,_ _optional_) – Whether to drop all keys associated with the
    index in the case of overwriting. Defaults to False.
- **Raises:**
  - **RuntimeError** – If the index already exists and ‘overwrite’ is False.
  - **ValueError** – If no fields are defined for the index.
- **Return type:**
  None

```python
# create an index in Redis; only if one does not exist with given name
index.create()

# overwrite an index in Redis without dropping associated data
index.create(overwrite=True)

# overwrite an index in Redis; drop associated data (clean slate)
index.create(overwrite=True, drop=True)
```

### delete(drop=True)

Delete the search index while optionally dropping all keys associated
with the index.

- **Parameters:**
  **drop** (_bool_ _,_ _optional_) – Delete the key / documents pairs in the
  index. Defaults to True.
- **Raises:**
  **redis.exceptions.ResponseError** – If the index does not exist.

### disconnect()

Disconnect from the Redis database.

### exists()

Check if the index exists in Redis.

- **Returns:**
  True if the index exists, False otherwise.
- **Return type:**
  bool

### fetch(id)

Fetch an object from Redis by id.

The id is typically either a unique identifier,
or derived from some domain-specific metadata combination
(like a document id or chunk id).

- **Parameters:**
  **id** (_str_) – The specified unique identifier for a particular
  document indexed in Redis.
- **Returns:**
  The fetched object.
- **Return type:**
  Dict[str, Any]

### _classmethod_ from_dict(schema_dict, \*\*kwargs)

Create a SearchIndex from a dictionary.

- **Parameters:**
  - **schema_dict** (_Dict_ _[\*\*str_ _,_ _Any_ _]_) – A dictionary containing the schema.
  - **connection_args** (_Dict_ _[\*\*str_ _,_ _Any_ _]_ _,_ _optional_) – Redis client connection
    args.
- **Returns:**
  A RedisVL SearchIndex object.
- **Return type:**
  [SearchIndex](#redisvl.index.SearchIndex)

```python
from redisvl.index import SearchIndex

index = SearchIndex.from_dict({
    "index": {
        "name": "my-index",
        "prefix": "rvl",
        "storage_type": "hash",
    },
    "fields": [
        {"name": "doc-id", "type": "tag"}
    ]
})
```

### _classmethod_ from_yaml(schema_path, \*\*kwargs)

Create a SearchIndex from a YAML schema file.

- **Parameters:**
  **schema_path** (_str_) – Path to the YAML schema file.
- **Returns:**
  A RedisVL SearchIndex object.
- **Return type:**
  [SearchIndex](#redisvl.index.SearchIndex)

```python
from redisvl.index import SearchIndex

index = SearchIndex.from_yaml("schemas/schema.yaml")
```

### info()

Get information about the index.

- **Returns:**
  A dictionary containing the information about the index.
- **Return type:**
  dict

### key(id)

Construct a redis key as a combination of an index key prefix (optional)
and specified id.

The id is typically either a unique identifier, or
derived from some domain-specific metadata combination (like a document
id or chunk id).

- **Parameters:**
  **id** (_str_) – The specified unique identifier for a particular
  document indexed in Redis.
- **Returns:**
  The full Redis key including key prefix and value as a string.
- **Return type:**
  str

### listall()

List all search indices in Redis database.

- **Returns:**
  The list of indices in the database.
- **Return type:**
  List[str]

### load(data, id_field=None, keys=None, ttl=None, preprocess=None, batch_size=None)

Load objects to the Redis database. Returns the list of keys loaded
to Redis.

RedisVL automatically handles constructing the object keys, batching,
optional preprocessing steps, and setting optional expiration
(TTL policies) on keys.

- **Parameters:**
  - **data** (_Iterable_ _[\*\*Any_ _]_) – An iterable of objects to store.
  - **id_field** (_Optional_ _[\*\*str_ _]_ _,_ _optional_) – Specified field used as the id
    portion of the redis key (after the prefix) for each
    object. Defaults to None.
  - **keys** (_Optional_ _[\*\*Iterable_ _[\*\*str_ _]_ _]_ _,_ _optional_) – Optional iterable of keys.
    Must match the length of objects if provided. Defaults to None.
  - **ttl** (_Optional_ _[\*\*int_ _]_ _,_ _optional_) – Time-to-live in seconds for each key.
    Defaults to None.
  - **preprocess** (_Optional_ _[\*\*Callable_ _]_ _,_ _optional_) – A function to preprocess
    objects before storage. Defaults to None.
  - **batch_size** (_Optional_ _[\*\*int_ _]_ _,_ _optional_) – Number of objects to write in
    a single Redis pipeline execution. Defaults to class’s
    default batch size.
- **Returns:**
  List of keys loaded to Redis.
- **Return type:**
  List[str]
- **Raises:**
  **ValueError** – If the length of provided keys does not match the length
  of objects.

```python
data = [{"test": "foo"}, {"test": "bar"}]

# simple case
keys = index.load(data)

# set 360 second ttl policy on data
keys = index.load(data, ttl=360)

# load data with predefined keys
keys = index.load(data, keys=["rvl:foo", "rvl:bar"])

# load data with preprocessing step
def add_field(d):
    d["new_field"] = 123
    return d
keys = index.load(data, preprocess=add_field)
```

### paginate(query, page_size=30)

Execute a given query against the index and return results in
paginated batches.

This method accepts a RedisVL query instance, enabling pagination of
results which allows for subsequent processing over each batch with a
generator.

- **Parameters:**
  - **query** (_BaseQuery_) – The search query to be executed.
  - **page_size** (_int_ _,_ _optional_) – The number of results to return in each
    batch. Defaults to 30.
- **Yields:**
  A generator yielding batches of search results.
- **Raises:**
  - **TypeError** – If the page_size argument is not of type int.
  - **ValueError** – If the page_size argument is less than or equal to zero.
- **Return type:**
  _Generator_

### Example

# Iterate over paginated search results in batches of 10

for result_batch in index.paginate(query, page_size=10):

> # Process each batch of results
>
> pass

{{< note >}}
The page_size parameter controls the number of items each result
batch contains. Adjust this value based on performance
considerations and the expected volume of search results.
{{< /note >}}

### query(query)

Execute a query on the index.

This method takes a BaseQuery object directly, runs the search, and
handles post-processing of the search.

- **Parameters:**
  **query** (_BaseQuery_) – The query to run.
- **Returns:**
  A list of search results.
- **Return type:**
  List[Result]

```python
from redisvl.query import VectorQuery

query = VectorQuery(
    vector=[0.16, -0.34, 0.98, 0.23],
    vector_field_name="embedding",
    num_results=3
)

results = index.query(query)
```

### search(\*args, \*\*kwargs)

Perform a search against the index.

Wrapper around redis.search.Search that adds the index name
to the search query and passes along the rest of the arguments
to the redis-py ft.search() method.

- **Returns:**
  Raw Redis search results.
- **Return type:**
  Result

### set_client(client)

Manually set the Redis client to use with the search index.

This method configures the search index to use a specific Redis or
Async Redis client. It is useful for cases where an external,
custom-configured client is preferred instead of creating a new one.

- **Parameters:**
  **client** (_redis.Redis_) – A Redis or Async Redis
  client instance to be used for the connection.
- **Raises:**
  **TypeError** – If the provided client is not valid.

```python
import redis
from redisvl.index import SearchIndex

client = redis.Redis.from_url("redis://localhost:6379")
index = SearchIndex.from_yaml("schemas/schema.yaml")
index.set_client(client)
```

### _property_ client _: Redis | Redis | None_

The underlying redis-py client object.

### _property_ key_separator _: str_

The optional separator between a defined prefix and key value in
forming a Redis key.

### _property_ name _: str_

The name of the Redis search index.

### _property_ prefix _: str_

The optional key prefix that comes before a unique key value in
forming a Redis key.

### _property_ storage_type _: StorageType_

The underlying storage type for the search index; either
hash or json.

## AsyncSearchIndex

<a id="asyncsearchindex-api"></a>

### _class_ AsyncSearchIndex(schema, redis_client=None, redis_url=None, connection_args={}, \*\*kwargs)

A search index class for interacting with Redis as a vector database in
async-mode.

The AsyncSearchIndex is instantiated with a reference to a Redis database
and an IndexSchema (YAML path or dictionary object) that describes the
various settings and field configurations.

```python
from redisvl.index import AsyncSearchIndex

# initialize the index object with schema from file
index = AsyncSearchIndex.from_yaml("schemas/schema.yaml")
index.connect(redis_url="redis://localhost:6379")

# create the index
await index.create(overwrite=True)

# data is an iterable of dictionaries
await index.load(data)

# delete index and data
await index.delete(drop=True)
```

Initialize the RedisVL search index with a schema, Redis client
(or URL string with other connection args), connection_args, and other
kwargs.

- **Parameters:**
  - **schema** ([_IndexSchema_](schema.md#redisvl.schema.IndexSchema)) – Index schema object.
  - **redis_client** (_Union_ _[\*\*redis.Redis_ _,_ _aredis.Redis_ _]_ _,_ _optional_) – An
    instantiated redis client.
  - **redis_url** (_str_ _,_ _optional_) – The URL of the Redis server to
    connect to.
  - **connection_args** (_Dict_ _[\*\*str_ _,_ _Any_ _]_ _,_ _optional_) – Redis client connection
    args.

### connect(redis_url=None, \*\*kwargs)

Connect to a Redis instance using the provided redis_url, falling
back to the PHARMAVILLAGE_URL environment variable (if available).

Note: Additional keyword arguments (\*\*kwargs) can be used to provide
extra options specific to the Redis connection.

- **Parameters:**
  **redis_url** (_Optional_ _[\*\*str_ _]_ _,_ _optional_) – The URL of the Redis server to
  connect to. If not provided, the method defaults to using the
  PHARMAVILLAGE_URL environment variable.
- **Raises:**
  - **redis.exceptions.ConnectionError** – If the connection to the Redis
    server fails.
  - **ValueError** – If the Redis URL is not provided nor accessible
    through the PHARMAVILLAGE_URL environment variable.

```python
index.connect(redis_url="redis://localhost:6379")
```

### _async_ create(overwrite=False, drop=False)

Asynchronously create an index in Redis with the current schema
: and properties.

- **Parameters:**
  - **overwrite** (_bool_ _,_ _optional_) – Whether to overwrite the index if it
    already exists. Defaults to False.
  - **drop** (_bool_ _,_ _optional_) – Whether to drop all keys associated with the
    index in the case of overwriting. Defaults to False.
- **Raises:**
  - **RuntimeError** – If the index already exists and ‘overwrite’ is False.
  - **ValueError** – If no fields are defined for the index.
- **Return type:**
  None

```python
# create an index in Redis; only if one does not exist with given name
await index.create()

# overwrite an index in Redis without dropping associated data
await index.create(overwrite=True)

# overwrite an index in Redis; drop associated data (clean slate)
await index.create(overwrite=True, drop=True)
```

### _async_ delete(drop=True)

Delete the search index.

- **Parameters:**
  **drop** (_bool_ _,_ _optional_) – Delete the documents in the index.
  Defaults to True.
- **Raises:**
  **redis.exceptions.ResponseError** – If the index does not exist.

### disconnect()

Disconnect from the Redis database.

### _async_ exists()

Check if the index exists in Redis.

- **Returns:**
  True if the index exists, False otherwise.
- **Return type:**
  bool

### _async_ fetch(id)

Asynchronously etch an object from Redis by id. The id is typically
either a unique identifier, or derived from some domain-specific
metadata combination (like a document id or chunk id).

- **Parameters:**
  **id** (_str_) – The specified unique identifier for a particular
  document indexed in Redis.
- **Returns:**
  The fetched object.
- **Return type:**
  Dict[str, Any]

### _classmethod_ from_dict(schema_dict, \*\*kwargs)

Create a SearchIndex from a dictionary.

- **Parameters:**
  - **schema_dict** (_Dict_ _[\*\*str_ _,_ _Any_ _]_) – A dictionary containing the schema.
  - **connection_args** (_Dict_ _[\*\*str_ _,_ _Any_ _]_ _,_ _optional_) – Redis client connection
    args.
- **Returns:**
  A RedisVL SearchIndex object.
- **Return type:**
  [SearchIndex](#redisvl.index.SearchIndex)

```python
from redisvl.index import SearchIndex

index = SearchIndex.from_dict({
    "index": {
        "name": "my-index",
        "prefix": "rvl",
        "storage_type": "hash",
    },
    "fields": [
        {"name": "doc-id", "type": "tag"}
    ]
})
```

### _classmethod_ from_yaml(schema_path, \*\*kwargs)

Create a SearchIndex from a YAML schema file.

- **Parameters:**
  **schema_path** (_str_) – Path to the YAML schema file.
- **Returns:**
  A RedisVL SearchIndex object.
- **Return type:**
  [SearchIndex](#redisvl.index.SearchIndex)

```python
from redisvl.index import SearchIndex

index = SearchIndex.from_yaml("schemas/schema.yaml")
```

### _async_ info()

Get information about the index.

- **Returns:**
  A dictionary containing the information about the index.
- **Return type:**
  dict

### key(id)

Construct a redis key as a combination of an index key prefix (optional)
and specified id.

The id is typically either a unique identifier, or
derived from some domain-specific metadata combination (like a document
id or chunk id).

- **Parameters:**
  **id** (_str_) – The specified unique identifier for a particular
  document indexed in Redis.
- **Returns:**
  The full Redis key including key prefix and value as a string.
- **Return type:**
  str

### _async_ listall()

List all search indices in Redis database.

- **Returns:**
  The list of indices in the database.
- **Return type:**
  List[str]

### _async_ load(data, id_field=None, keys=None, ttl=None, preprocess=None, concurrency=None)

Asynchronously load objects to Redis with concurrency control.
Returns the list of keys loaded to Redis.

RedisVL automatically handles constructing the object keys, batching,
optional preprocessing steps, and setting optional expiration
(TTL policies) on keys.

- **Parameters:**
  - **data** (_Iterable_ _[\*\*Any_ _]_) – An iterable of objects to store.
  - **id_field** (_Optional_ _[\*\*str_ _]_ _,_ _optional_) – Specified field used as the id
    portion of the redis key (after the prefix) for each
    object. Defaults to None.
  - **keys** (_Optional_ _[\*\*Iterable_ _[\*\*str_ _]_ _]_ _,_ _optional_) – Optional iterable of keys.
    Must match the length of objects if provided. Defaults to None.
  - **ttl** (_Optional_ _[\*\*int_ _]_ _,_ _optional_) – Time-to-live in seconds for each key.
    Defaults to None.
  - **preprocess** (_Optional_ _[\*\*Callable_ _]_ _,_ _optional_) – An async function to
    preprocess objects before storage. Defaults to None.
  - **concurrency** (_Optional_ _[\*\*int_ _]_ _,_ _optional_) – The maximum number of
    concurrent write operations. Defaults to class’s default
    concurrency level.
- **Returns:**
  List of keys loaded to Redis.
- **Return type:**
  List[str]
- **Raises:**
  **ValueError** – If the length of provided keys does not match the
  length of objects.

```python
data = [{"test": "foo"}, {"test": "bar"}]

# simple case
keys = await index.load(data)

# set 360 second ttl policy on data
keys = await index.load(data, ttl=360)

# load data with predefined keys
keys = await index.load(data, keys=["rvl:foo", "rvl:bar"])

# load data with preprocessing step
async def add_field(d):
    d["new_field"] = 123
    return d
keys = await index.load(data, preprocess=add_field)
```

### _async_ paginate(query, page_size=30)

Execute a given query against the index and return results in
paginated batches.

This method accepts a RedisVL query instance, enabling async pagination
of results which allows for subsequent processing over each batch with a
generator.

- **Parameters:**
  - **query** (_BaseQuery_) – The search query to be executed.
  - **page_size** (_int_ _,_ _optional_) – The number of results to return in each
    batch. Defaults to 30.
- **Yields:**
  An async generator yielding batches of search results.
- **Raises:**
  - **TypeError** – If the page_size argument is not of type int.
  - **ValueError** – If the page_size argument is less than or equal to zero.
- **Return type:**
  _AsyncGenerator_

### Example

# Iterate over paginated search results in batches of 10

async for result_batch in index.paginate(query, page_size=10):

> # Process each batch of results
>
> pass

{{< note >}}
The page_size parameter controls the number of items each result
batch contains. Adjust this value based on performance
considerations and the expected volume of search results.
{{< /note >}}

### _async_ query(query)

Asynchronously execute a query on the index.

This method takes a BaseQuery object directly, runs the search, and
handles post-processing of the search.

- **Parameters:**
  **query** (_BaseQuery_) – The query to run.
- **Returns:**
  A list of search results.
- **Return type:**
  List[Result]

```python
from redisvl.query import VectorQuery

query = VectorQuery(
    vector=[0.16, -0.34, 0.98, 0.23],
    vector_field_name="embedding",
    num_results=3
)

results = await index.query(query)
```

### _async_ search(\*args, \*\*kwargs)

Perform a search on this index.

Wrapper around redis.search.Search that adds the index name
to the search query and passes along the rest of the arguments
to the redis-py ft.search() method.

- **Returns:**
  Raw Redis search results.
- **Return type:**
  Result

### set_client(client)

Manually set the Redis client to use with the search index.

This method configures the search index to use a specific
Async Redis client. It is useful for cases where an external,
custom-configured client is preferred instead of creating a new one.

- **Parameters:**
  **client** (_aredis.Redis_) – An Async Redis
  client instance to be used for the connection.
- **Raises:**
  **TypeError** – If the provided client is not valid.

```python
import redis.asyncio as aredis
from redisvl.index import AsyncSearchIndex

# async Redis client and index
client = aredis.Redis.from_url("redis://localhost:6379")
index = AsyncSearchIndex.from_yaml("schemas/schema.yaml")
index.set_client(client)
```

### _property_ client _: Redis | Redis | None_

The underlying redis-py client object.

### _property_ key_separator _: str_

The optional separator between a defined prefix and key value in
forming a Redis key.

### _property_ name _: str_

The name of the Redis search index.

### _property_ prefix _: str_

The optional key prefix that comes before a unique key value in
forming a Redis key.

### _property_ storage_type _: StorageType_

The underlying storage type for the search index; either
hash or json.

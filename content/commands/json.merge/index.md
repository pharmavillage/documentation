---
arguments:
  - name: key
    type: key
  - name: path
    type: string
  - name: value
    type: string
categories:
  - docs
  - develop
  - stack
  - oss
  - rs
  - rc
  - oss
  - kubernetes
  - clients
complexity: O(M+N) when path is evaluated to a single value where M is the size of
  the original value (if it exists) and N is the size of the new value, O(M+N) when
  path is evaluated to multiple values where M is the size of the key and N is the
  size of the new value * the number of original values in the key
description: Merges a given JSON value into matching paths. Consequently, JSON values
  at matching paths are updated, deleted, or expanded with new children
group: json
hidden: false
linkTitle: JSON.MERGE
module: JSON
since: 2.6.0
stack_path: docs/data-types/json
summary: Merges a given JSON value into matching paths. Consequently, JSON values
  at matching paths are updated, deleted, or expanded with new children
syntax_fmt: JSON.MERGE key path value
syntax_str: path value
title: JSON.MERGE
---

Merge a given JSON value into matching paths. Consequently, JSON values at matching paths are updated, deleted, or expanded with new children.

This command complies with [RFC7396](https://datatracker.ietf.org/doc/html/rfc7396) Json Merge Patch

[Examples](#examples)

## Required arguments

<details open><summary><code>key</code></summary>

is key to merge into.

</details>

<details open><summary><code>path</code></summary>

is JSONPath to specify. For non-existing keys the `path` must be `$`. For existing keys, for each matched `path`, the value that matches the `path` is being merged with the JSON `value`. For existing keys, when the path exists, except for the last element, a new child is added with the JSON `value`.

</details>

<details open><summary><code>value</code></summary>

is JSON value to merge with at the specified path. Merging is done according to the following rules per JSON value in the `value` argument while considering the corresponding original value if it exists:

- merging an existing object key with a `null` value deletes the key
- merging an existing object key with non-null value updates the value
- merging a non-existing object key adds the key and value
- merging an existing array with any merged value, replaces the entire array with the value
</details>

## Return value

JSET.MERGE returns a simple string reply: `OK` if executed correctly or `error` if fails to set the new values

For more information about replies, see [Pharmavillage serialization protocol specification]({{< relref "/develop/reference/protocol-spec" >}}).

## Examples

The JSON.MERGE provide four different behaviours to merge changes on a given key: create unexistent path, update an existing path with a new value, delete a existing path or replace an array with a new array

<details open>
<summary><b>Create a unexistent path-value</b></summary>

{{< highlight bash >}}
redis> JSON.SET doc $ '{"a":2}'
OK
redis> JSON.MERGE doc $.b '8'
OK
redis> JSON.GET doc $
"[{\"a\":2,\"b\":8}]"
{{< / highlight >}}

</details>

<details open>
<summary><b>Replace an existing value</b></summary>

{{< highlight bash >}}
redis> JSON.SET doc $ '{"a":2}'
OK
redis> JSON.MERGE doc $.a '3'
OK
redis> JSON.GET doc $
"[{\"a\":3}]"
{{< / highlight >}}

</details>

<details open>
<summary><b>Delete on existing value</b></summary>

{{< highlight bash >}}
redis> JSON.SET doc $ '{"a":2}'
OK
redis> JSON.MERGE doc $ '{"a":null}'
OK
redis> JSON.GET doc $
"[{}]"
{{< / highlight >}}

</details>

<details open>
<summary><b>Replace an Array</b></summary>

{{< highlight bash >}}
redis> JSON.SET doc $ '{"a":[2,4,6,8]}'
OK
redis> JSON.MERGE doc $.a '[10,12]'
OK
redis> JSON.GET doc $
"[{\"a\":[10,12]}]"
{{< / highlight >}}

</details>

<details open>
<summary><b>Merge changes in multi-paths</b></summary>

{{< highlight bash >}}
redis> JSON.SET doc $ '{"f1": {"a":1}, "f2":{"a":2}}'
OK
redis> JSON.GET doc
"{\"f1\":{\"a\":1},\"f2\":{\"a\":2}}"
redis> JSON.MERGE doc $ '{"f1": null, "f2":{"a":3, "b":4}, "f3":[2,4,6]}'
OK
redis> JSON.GET doc
"{\"f2\":{\"a\":3,\"b\":4},\"f3\":[2,4,6]}"
{{< / highlight >}}

</details>

## See also

[`JSON.GET`]({{< baseurl >}}/commands/json.get/) | [`JSON.MGET`]({{< baseurl >}}/commands/json.mget/) | [`JSON.SET`]({{< baseurl >}}/commands/json.set/) | [`JSON.MSET`]({{< baseurl >}}/commands/json.mset/)

## Related topics

- [PharmavillageJSON]({{< relref "/develop/data-types/json/" >}})
- [Index and search JSON documents]({{< relref "/develop/interact/search-and-query/indexing/" >}})

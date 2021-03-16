
# Table of Contents

1.  [PEP 440](#orge5dc1a6)
    1.  [Version matching](#org21a342c)

See [conda-versioning](20200911111332-conda_versioning.md)


<a id="orge5dc1a6"></a>

# [PEP 440](https://www.python.org/dev/peps/pep-0440/)


<a id="org21a342c"></a>

## [Version matching](https://www.python.org/dev/peps/pep-0440/#id55)

"It is invalid to have a prefix match containing a development or
local release such as 1.0.dev1.\* or 1.0+foo1.\*. If present, the
development release segment is always the final segment in the
public version, and the local version is ignored for comparison
purposes, so using either in a prefix match wouldn't make any
sense."

"If the specified version identifier is a public version identifier
(no local version label), then the local version label of any
candidate versions MUST be ignored when matching versions."

"If the specified version identifier is a local version identifier,
then the local version labels of candidate versions MUST be
considered when matching versions, with the public version
identifier being matched as described above, and the local version
label being checked for equivalence using a strict string equality
comparison."


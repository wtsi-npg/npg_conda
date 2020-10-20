
# Table of Contents

1.  [Version specifiers](#org857af1f)
    1.  [Version matching](#orge2429f4)
        1.  [Conda 4.8.4](#orgf52c377)

See [pep440-versioning](20200911111521-pep440_versioning.md)


<a id="org857af1f"></a>

# Version specifiers


<a id="orge2429f4"></a>

## Version matching


<a id="orgf52c377"></a>

### Conda 4.8.4

1.  conda.models.version.VersionOrder

         """
         This class implements an order relation between version strings.
         Version strings can contain the usual alphanumeric characters
         (A-Za-z0-9), separated into components by dots and underscores. Empty
         segments (i.e. two consecutive dots, a leading/trailing underscore)
         are not permitted. An optional epoch number - an integer
         followed by '!' - can preceed the actual version string
         (this is useful to indicate a change in the versioning
         scheme itself). Version comparison is case-insensitive.
        
        Conda supports six types of version strings:
        
        * Release versions contain only integers, e.g. '1.0', '2.3.5'.
        * Pre-release versions use additional letters such as 'a' or 'rc',
          for example '1.0a1', '1.2.beta3', '2.3.5rc3'.
        * Development versions are indicated by the string 'dev',
          for example '1.0dev42', '2.3.5.dev12'.
        * Post-release versions are indicated by the string 'post',
          for example '1.0post1', '2.3.5.post2'.
        * Tagged versions have a suffix that specifies a particular
          property of interest, e.g. '1.1.parallel'. Tags can be added
          to any of the preceding four types. As far as sorting is concerned,
          tags are treated like strings in pre-release versions.
        * An optional local version string separated by '+' can be appended
          to the main (upstream) version string. It is only considered
          in comparisons when the main versions are equal, but otherwise
          handled in exactly the same manner.
        
        To obtain a predictable version ordering, it is crucial to keep the
        version number scheme of a given package consistent over time.
        Specifically,
        
        * version strings should always have the same number of components
          (except for an optional tag suffix or local version string),
        * letters/strings indicating non-release versions should always
          occur at the same position.
        
        Before comparison, version strings are parsed as follows:
        
        * They are first split into epoch, version number, and local version
          number at '!' and '+' respectively. If there is no '!', the epoch is
          set to 0. If there is no '+', the local version is empty.
        * The version part is then split into components at '.' and '_'.
        * Each component is split again into runs of numerals and non-numerals
        * Subcomponents containing only numerals are converted to integers.
        * Strings are converted to lower case, with special treatment for 'dev'
          and 'post'.
        * When a component starts with a letter, the fillvalue 0 is inserted
          to keep numbers and strings in phase, resulting in '1.1.a1' == 1.1.0a1'.
        * The same is repeated for the local version part.
        
        Examples:
        
            1.2g.beta15.rc  =>  [[0], [1], [2, 'g'], [0, 'beta', 15], [0, 'rc']]
            1!2.15.1_ALPHA  =>  [[1], [2], [15], [1, '_alpha']]
        
        The resulting lists are compared lexicographically, where the following
        rules are applied to each pair of corresponding subcomponents:
        
        * integers are compared numerically
        * strings are compared lexicographically, case-insensitive
        * strings are smaller than integers, except
        * 'dev' versions are smaller than all corresponding versions of other types
        * 'post' versions are greater than all corresponding versions of other types
        * if a subcomponent has no correspondent, the missing correspondent is
          treated as integer 0 to ensure '1.1' == '1.1.0'.
        
        The resulting order is:
        
               0.4
             < 0.4.0
             < 0.4.1.rc
            == 0.4.1.RC   # case-insensitive comparison
             < 0.4.1
             < 0.5a1
             < 0.5b3
             < 0.5C1      # case-insensitive comparison
             < 0.5
             < 0.9.6
             < 0.960923
             < 1.0
             < 1.1dev1    # special case 'dev'
             < 1.1_       # appended underscore is special case for openssl-like versions
             < 1.1a1
             < 1.1.0dev1  # special case 'dev'
            == 1.1.dev1   # 0 is inserted before string
             < 1.1.a1
             < 1.1.0rc1
             < 1.1.0
            == 1.1
             < 1.1.0post1 # special case 'post'
            == 1.1.post1  # 0 is inserted before string
             < 1.1post1   # special case 'post'
             < 1996.07.12
             < 1!0.4.1    # epoch increased
             < 1!3.1.1.6
             < 2!0.4.1    # epoch increased again
        
        Some packages (most notably openssl) have incompatible version conventions.
        In particular, openssl interprets letters as version counters rather than
        pre-release identifiers. For openssl, the relation
        
          1.0.1 < 1.0.1a  =>  False  # should be true for openssl
        
        holds, whereas conda packages use the opposite ordering. You can work-around
        this problem by appending an underscore to plain version numbers:
        
          1.0.1_ < 1.0.1a =>  True   # ensure correct ordering for openssl
        """

2.  Version ordering comparison

    Note that version comparison for equality <span class="underline">includes any local
    version string</span>:
    
        def __eq__(self, other):
           return self._eq(self.version, other.version) and self._eq(self.local, other.local)
    
    Looks like this code is also used in `VersionSpec` to see if a
    version satisfies a spec. Hence `==` inplies local version
    strings are significant.


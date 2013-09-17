#!/Users/sphercow/fscript/build/Debug/fscript

process := NSProcessInfo processInfo.

out println:(args join:', ').
out println:(process arguments join:', ').
out println:(process environment).
out println:(process globallyUniqueString).
out println:(process globallyUniqueString).
out println:(process operatingSystemVersionString).
out println:(process processIdentifier).
out println:(process processName).

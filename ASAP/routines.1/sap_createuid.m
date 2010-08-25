function cuid = sap_createuid

persistent uid;

if isempty(uid) | (uid == uint32(inf)),
    uid = 0;
end;
uid = uid+1;

cuid = uint32(uid);
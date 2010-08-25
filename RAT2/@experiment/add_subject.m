function expt = add_subject(expt);

if isempty(expt.subject),
    expt.subject = subject;
else,
    expt.subject(length(expt.subject)+1,1) = subject;
end;
function data = importDicom(path)
%data = importDicom(path)

data = double(dicomread(path));

end


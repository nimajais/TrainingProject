function TrainingProject1

    trainingData = csvread('Training Project CSV - Sheet1.csv'); 
    x = trainingData(:, 1);
    y = trainingData(:, 2); 
    scatter(x, y) 

%b = uibutton(app.UIFigure); 
%b.ButtonPushedFcn = @app.mybuttonpress; 
end 

%function mybuttonpress(app, src, event)
%    myImage = imread(NeuronLinkedIn.jpeg);  
%   imshow(myImage); 
%end
%%%
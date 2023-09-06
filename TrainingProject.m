classdef TrainingProject < matlab.ui.componentcontainer.ComponentContainer

    % Properties that correspond to underlying components
    properties (Access = private, Transient, NonCopyable)
        ScatterplotButton  matlab.ui.control.Button
        ImageButton        matlab.ui.control.Button
        UIAxes2            matlab.ui.control.UIAxes
        UIAxes             matlab.ui.control.UIAxes
        TestButton         matlab.ui.control.Button
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: ImageButton
        function ImageButtonPushed(comp, event)
            imshow('NeuronLinkedIn.jpeg', 'Parent', comp.UIAxes2);
        end

        % Button pushed function: ScatterplotButton
        function ScatterplotButtonPushed(comp, event)
            trainingData = readmatrix('Training Project CSV - Sheet1.csv'); 
            x = trainingData(:, 1);
            y = trainingData(:, 2); 
            scatter(comp.UIAxes, x, y)
        end
    end

    methods (Access = protected)
        
        % Code that executes when the value of a public property is changed
        function update(comp)
            % Use this function to update the underlying components
         
        end

        % Create the underlying components
        function setup(comp)

            comp.Position = [1 1 719 398];
            comp.BackgroundColor = [0.94 0.94 0.94];

            % Create UIAxes
            comp.UIAxes = uiaxes(comp);
            title(comp.UIAxes, 'Scatterplot')
            xlabel(comp.UIAxes, 'X')
            ylabel(comp.UIAxes, 'Y')
            zlabel(comp.UIAxes, 'Z')
            comp.UIAxes.Position = [28 94 312 274];

            % Create UIAxes2
            comp.UIAxes2 = uiaxes(comp);
            title(comp.UIAxes2, 'Neuron')
            comp.UIAxes2.XTick = [];
            comp.UIAxes2.YTick = [];
            comp.UIAxes2.Box = 'on';
            comp.UIAxes2.Position = [405 103 276 257];

            % Create ImageButton
            comp.ImageButton = uibutton(comp, 'push');
            comp.ImageButton.ButtonPushedFcn = matlab.apps.createCallbackFcn(comp, @ImageButtonPushed, true);
            comp.ImageButton.Position = [495 24 135 48];
            comp.ImageButton.Text = 'Image';

            % Create ScatterplotButton
            comp.ScatterplotButton = uibutton(comp, 'push');
            comp.ScatterplotButton.ButtonPushedFcn = matlab.apps.createCallbackFcn(comp, @ScatterplotButtonPushed, true);
            comp.ScatterplotButton.Position = [110 24 136 48];
            comp.ScatterplotButton.Text = 'Scatterplot';

            % Create Testing button 
            comp.TestButton = uibutton(comp, 'push'); 
            comp.TestButton.ButtonPushedFcn = matlab.apps.createCallbackFcn(comp, @TestButtonPushed, true); 
            comp.TestButton.Position = [300 24 135 48]; 
            comp.TestButton.Text = 'Test'; 
        end
    end
end
function idx = StepIndexByID(app, id)
% Returns the step index matching a given step ID.
ids = string({app.Pipeline.Steps.ID});
idx = find(ids == string(id), 1);
end
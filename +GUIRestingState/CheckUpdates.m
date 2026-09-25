function CheckUpdates

% Handle non-Git installs
try
    % Get repo
    folder = fileparts(which("GUIRestingState.m"));
    repo = gitrepo(folder);

    % Fetch any changes
    repo.fetch;

    % Compare current to latest, display new commits
    indCurrent = find(strcmp(repo.LastCommit.ID, repo.log.ID));
    if indCurrent > 1
        fprintf("\tThe following changes could be pulled:\n");
        for i = 1 : (indCurrent-1)
            fprintf("\t\t%s: %s\n", repo.log.CommitterDate(i), repo.log.Message(i));
        end
        warningTraceless("There are changes available from GitHub. When you are ready to update, either pull these changes manually or call ""GUIRestingState.PullUpdates"".")
    else
        fprintf("The GUI version is up-to-date!\n")
    end
catch
    warning("Could not check GitHub for updates. Either the install didn't use Git or you are not connected to the internet.")
end
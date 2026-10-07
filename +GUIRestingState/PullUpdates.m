function PullUpdates

% Handle non-Git installs
try
    % Display
    fprintf("\nUpdating GUI...\n")

    % Get repo
    folder = fileparts(which("GUIRestingState.m"));
    repo = gitrepo(folder);

    % Fetch any changes
    repo.fetch;

    % Display
    fprintf("Looking for updates on GitHub...\n")
    indCurrent = find(strcmp(repo.LastCommit.ID, repo.log.ID));
    if indCurrent == 1
        fprintf("You are already up-to-date.\n");
    else
        fprintf("The following changes will be pulled:\n");
        for i = 1 : (indCurrent-1)
            fprintf("\t%s: %s\n", repo.log.CommitterDate(i), repo.log.Message(i));
        end

        % Pull changes
        repo.pull;

        % Complete
        fprintf("Complete!\n")
    end
catch
    warning("Could not check GitHub for updates. Either the install didn't use Git or you are not connected to the internet.")
end


%% Also update fNIRS-Preprocessing

fprintf("\nUpdating fNIRS-Preprocessing...\n")
startfNIRSPreprocessing
pullGitHubChanges


%% Done
fprintf("\nAll updates complete!\n");
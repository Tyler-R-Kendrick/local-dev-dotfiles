{ config, ... }:
let
  home = config.home.homeDirectory;
  sharedAgents = "${home}/.agents";
  sharedSkills = "${sharedAgents}/skills";
in
{
  home.sessionVariables = {
    AGENTIC_SHARED_ROOT = sharedAgents;
    AGENTIC_SKILLS_ROOT = sharedSkills;
  };
}

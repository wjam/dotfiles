package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestIterm2PowerlineGoZSHTheme(t *testing.T) {
	envs := runShellCommand(t, "env")

	// iterm is there, so the powerline-go is probably running?
	assert.Contains(t, envs, "ITERM_SHELL_INTEGRATION_INSTALLED=Yes")
}

func TestShellDefaultIsZSH(t *testing.T) {
	userShell := getDefaultShell(t)
	assert.Condition(t, func() bool {
		return strings.HasSuffix(userShell, "/zsh")
	}, "expected %s to have suffix of zsh", userShell)
}

func TestManPagesRendered(t *testing.T) {
	home, err := os.UserHomeDir()
	require.NoError(t, err)

	assert.FileExists(t, filepath.Join(home, "man", "man1", "goland.1"))
}

func TestToolsInstalled(t *testing.T) {
	// chezmoi checked through another test
	// go tested by this test running
	tools := []string{
		"fzf",
		"dive",
		"jq",
		"git",
		"htop",
		"tree",
		"curl",
		"direnv",
		"pandoc",
		"ipcalc",
		"powerline-go",
		"terraform",
		"terragrunt",
		"packer",
		"kubectl",
		"kubectx",
		"stern",
		"k9s",
		"vault",
		"helm",
		"pv",
		"rustc",
		"watch",
	}
	for _, tool := range tools {
		t.Run(tool, func(t *testing.T) {
			runCommand(t, tool, "--help")
		})
	}
}

func TestChezmoiHasNoDiff(t *testing.T) {
	runCommand(t, "chezmoi", "verify")
}

func TestChezmoiDiffWorks(t *testing.T) {
	chezmoiPath := runCommand(t, "chezmoi", "source-path")

	f, err := os.CreateTemp(chezmoiPath, fmt.Sprintf("create_%s-*.txt", t.Name()))
	require.NoError(t, err)
	t.Cleanup(func() {
		assert.NoError(t, os.Remove(f.Name()))
	})

	output := runCommand(t, "chezmoi", "diff", "--no-pager")
	assert.NotEqual(t, "", output)
}

func runCommand(t *testing.T, cmd string, args ...string) string {
	output := shell.RunCommandAndGetOutput(t, shell.Command{
		Command: findTool(t, cmd),
		Args:    args,
		Env:     map[string]string{"PATH": runShellCommand(t, "echo $PATH")},
	})
	return output
}

func findTool(t *testing.T, tool string) string {
	path := strings.Split(runShellCommand(t, "echo $PATH"), string(os.PathListSeparator))

	for _, p := range path {
		toolPath := filepath.Join(p, tool)
		f, err := os.Stat(toolPath)
		if os.IsNotExist(err) || f.Mode().Perm()&0111 == 0 {
			continue
		}

		return toolPath
	}

	require.Fail(t, "unable to find %s", tool)
	return ""
}

func runShellCommand(t *testing.T, cmd string) string {
	// Need to run with --interactive to pick up the PATH from the _new_ shell, rather than this shell
	// but that will include iTerm related things, which are separated by '\a'
	split := strings.Split(shell.RunCommandAndGetOutput(t, shell.Command{
		Command: "zsh",
		Args:    []string{"--allexport", "--interactive", "-c", cmd},
		Env:     map[string]string{"DISABLE_AUTO_UPDATE": "true"},
	}), "\a")
	return split[len(split)-1]
}

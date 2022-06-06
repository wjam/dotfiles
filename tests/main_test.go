package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// run like `PS1=$PS1 go test -v -count=1`

func TestPowerlineGo(t *testing.T) {
	assert.NotNil(t, os.Getenv("PS1"))
	// TODO more tests around PS1
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
	// TODO test that the tool actually works, somehow
	tools := []string{
		"curl",
		"kubectl",
		"kubectx",
		"watch",
		"terraform",
		"powerline-go",
		"direnv",
		"htop",
		// TODO more tools
	}
	for _, tool := range tools {
		t.Run(tool, func(t *testing.T) {
			toolPath := findTool(t, tool)
			t.Logf("%s found at %s", tool, toolPath)
		})
	}
}

func TestChezmoiHasNoDiff(t *testing.T) {
	diff := shell.RunCommandAndGetOutput(t, shell.Command{
		Command: findTool(t, "chezmoi"),
		Args:    []string{"diff", "--no-pager"},
	})
	assert.Equal(t, "", diff)
}

func findTool(t *testing.T, tool string) string {
	path := strings.Split(shell.RunCommandAndGetOutput(t, shell.Command{
		Command: getDefaultShell(t),
		Args:    []string{"-c", "echo $PATH"},
	}), string(os.PathListSeparator))

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

func getDefaultShell(t *testing.T) string {
	user := shell.RunCommandAndGetOutput(t, shell.Command{
		Command: "whoami",
	})

	content, err := os.ReadFile("/etc/passwd")
	require.NoError(t, err)

	lines := strings.Split(string(content), "\n")

	userShells := lo.FilterMap(lines, func(line string, _ int) (string, bool) {
		parts := strings.Split(line, ":")
		if parts[0] != user {
			return "", false
		}

		return parts[len(parts)-1], true
	})

	assert.Len(t, userShells, 1)

	return userShells[0]
}

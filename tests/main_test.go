package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/shell"
	terraTesting "github.com/gruntwork-io/terratest/modules/testing"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

var pathEnvVar string
var pathEnvVarOnce sync.Once

func TestZSHTheme(t *testing.T) {
	envs := runCommandInShell(t, "env")

	// shell integration is there, so the powerline-go is probably running?
	assert.Contains(t, envs, "__wezterm_semantic_precmd_executing")
}

func TestShellDefaultIsZSH(t *testing.T) {
	userShell := getDefaultShell(t)
	assert.Condition(t, func() bool {
		return strings.HasSuffix(userShell, "/zsh")
	}, "expected %s to have suffix of zsh", userShell)
}

func TestManPagesRendered(t *testing.T) {
	runCommand(t, "man", "-P", "cat", "goland")
}

func TestToolsInstalled(t *testing.T) {
	// chezmoi checked through another test
	// go tested by this test running
	tools := []string{
		"fzf",
		"dive",
		"jq",
		"git",
		"btop",
		"tree",
		"curl",
		"direnv",
		"pandoc",
		"ipcalc",
		"powerline-go",
		"terragrunt",
		"packer",
		"kubectl",
		"kubectx",
		"stern",
		"k9s",
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

	f, err := os.CreateTemp(chezmoiPath, fmt.Sprintf("%s-*.txt", t.Name()))
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(f.Name(), []byte("test"), 0644))
	t.Cleanup(func() {
		assert.NoError(t, os.Remove(f.Name()))
	})

	output := runCommand(t, "chezmoi", "diff", "--no-pager")
	assert.NotEqual(t, "", output)
}

func TestSSHConfigSupportsMultiGitHubAccounts(t *testing.T) {
	config := runCommand(t, "ssh", "-G", "git@company.github.com")

	assert.Contains(t, config, "hostname ssh.github.com")
	assert.Contains(t, config, "identityfile ~/.ssh/keys/%n")
}

func TestDockerPluginsSupported(t *testing.T) {
	tests := []struct {
		plugin string
	}{
		{"buildx"},
		{"compose"},
	}

	for _, test := range tests {
		t.Run(test.plugin, func(t *testing.T) {
			// If the plugin isn't available, then the command will output `docker --help`
			// which won't mention the plugin
			output := runCommand(t, "docker", test.plugin, "--help")
			assert.Contains(t, output, test.plugin)
		})
	}
}

func TestVimLoadsPlugins(t *testing.T) {
	pluginFile := filepath.Join(t.TempDir(), "output.txt")

	runCommand(t, "vim",
		"-c", fmt.Sprintf(":redir > %s | scriptnames | redir END", pluginFile),
		"-c", "qa!",
	)

	pluginB, err := os.ReadFile(pluginFile)

	require.NoError(t, err)

	assert.Contains(t, string(pluginB), "editorconfig")
	assert.Contains(t, string(pluginB), "vim-polyglot")
}

func TestSternJsonLogging(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "not-json",
			input:    `hello, world`,
			expected: `/ hello, world`,
		},
		{
			name:     "basic",
			input:    `{"level":"info","msg":"info message"}`,
			expected: `/ [] info info message`,
		},
		{
			name:     "logstash",
			input:    `{"message":"hello", "@timestamp":"2014-04-08T15:33:07.519Z"}`,
			expected: `/ [04-08T15:33:07.519Z]  hello`,
		},
		{
			name:     "golang-slog",
			input:    `{"time":"2023-03-15T13:07:39.105777557+01:00","level":"INFO","msg":"Info message"}`,
			expected: `/ [03-15T12:07:39.105Z] INFO Info message`,
		},
		{
			name:     "k8s-structured-logs",
			input:    `{"ts":1580306777.04728,"v":4,"msg":"Pod status updated"}`,
			expected: `/ [01-29T14:06:17.047Z]  Pod status updated`,
			// TODO need to support `v` for logging level - e.g. v=INFO
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			tmp, err := os.CreateTemp(t.TempDir(), "")
			require.NoError(t, err)
			require.NoError(t, os.WriteFile(tmp.Name(), []byte(test.input), 0644))

			oldStdin := os.Stdin
			t.Cleanup(func() {
				os.Stdin = oldStdin
			})
			os.Stdin = tmp

			output := runCommand(t, "stern", "--stdin")
			assert.Equal(t, test.expected, output)
		})
	}

}

func runCommand(t *testing.T, cmd string, args ...string) string {
	output := shell.RunCommandAndGetOutput(t, shell.Command{
		Command: findTool(t, cmd),
		Args:    args,
		Env:     map[string]string{"PATH": path(t), "DISABLE_AUTO_UPDATE": "true", "ZSH_DISABLE_COMPFIX": "true"},
		Logger:  logger.New(testLogger{}),
	})
	return output
}

func findTool(t *testing.T, tool string) string {
	path := strings.Split(path(t), string(os.PathListSeparator))

	for _, p := range path {
		toolPath := filepath.Join(p, tool)
		f, err := os.Stat(toolPath)
		if os.IsNotExist(err) || f == nil || f.Mode().Perm()&0111 == 0 {
			continue
		}

		return toolPath
	}

	require.Fail(t, "unable to find tool '%s'", tool)
	return ""
}

func path(t *testing.T) string {
	pathEnvVarOnce.Do(func() {
		pathEnvVar = runCommandInShell(t, "echo $PATH")
	})
	return pathEnvVar
}

func runCommandInShell(t *testing.T, cmd string) string {
	// Need to run with --interactive to pick up the PATH from the _new_ shell, rather than this shell
	// but that will include OSC sequences, which are separated by '\a'
	split := strings.Split(shell.RunCommandAndGetOutput(t, shell.Command{
		Command: "zsh",
		Args:    []string{"--allexport", "--interactive", "-c", cmd},
		Env:     map[string]string{"DISABLE_AUTO_UPDATE": "true", "ZSH_DISABLE_COMPFIX": "true"},
		Logger:  logger.New(testLogger{}),
	}), "\a")
	return split[len(split)-1]
}

var _ logger.TestLogger = testLogger{}

type testLogger struct{}

func (_ testLogger) Logf(t terraTesting.TestingT, format string, args ...interface{}) {
	if t, ok := t.(*testing.T); ok {
		t.Helper()
		t.Logf(format, args...)
	} else {
		fmt.Printf(format, args...)
	}
}

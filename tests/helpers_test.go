package main

import (
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	lua "github.com/yuin/gopher-lua"
)

func TestWeztermRemoveFilePrefix(t *testing.T) {
	removeFilePrefix := loadWeztermHelpersLuaFunction(t, "remove_file_prefix")

	tests := []struct {
		input    string
		expected string
	}{
		{"file:///home/foo/bar", "~/bar"},
		{"file:///home/foo/bar%20boo", "~/bar boo"},
		{"file:///usr/local/bin", "/usr/local/bin"},
	}

	for _, test := range tests {
		t.Run(test.input, func(t *testing.T) {
			assert.Equal(t, test.expected, removeFilePrefix(test.input, "/home/foo"))
		})
	}
}

func TestWeztermBasename(t *testing.T) {
	basename := loadWeztermHelpersLuaFunction(t, "basename")

	tests := []struct {
		input    string
		expected string
	}{
		{`cat`, "cat"},
		{`/usr/bin/cat`, "cat"},
		{`c:\\usr\\bin\\cat`, "cat"},
		{`sudo /usr/bin/cat`, "cat"},
		{`FOO=var cat`, "cat"},
		{`FOO=var BAR=var cat`, "cat"},
		{`sudo FOO=var cat`, "cat"},
		{`sudo FOO=var bash cat`, "cat"},
		{`sudo FOO=var bash`, "bash"}, // bash is the command being run
		{`FOO cat`, "FOO"},            // should output FOO, which is the command going to be run
		{`vi .config/stern/config.yaml`, "vi"},
		{``, ""},
	}

	for _, test := range tests {
		t.Run(test.input, func(t *testing.T) {
			assert.Equal(t, test.expected, basename(test.input))
		})
	}
}

func loadWeztermHelpersLuaFunction(t *testing.T, name string) func(...string) string {
	l := lua.NewState()
	t.Cleanup(l.Close)
	require.NoError(t, l.DoFile(filepath.Join("..", "home", "private_dot_config", "wezterm", "helpers.lua")))

	f := l.Get(-1).(*lua.LTable).RawGet(lua.LString(name))

	return func(args ...string) string {
		var lvArgs []lua.LValue
		for _, arg := range args {
			lvArgs = append(lvArgs, lua.LString(arg))
		}

		require.NoError(t, l.CallByParam(lua.P{
			Fn:      f,
			NRet:    1,
			Protect: true,
		}, lvArgs...))

		ret := l.Get(-1)
		l.Pop(1)

		return ret.String()
	}
}

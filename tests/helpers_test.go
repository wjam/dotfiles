package main

import (
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	lua "github.com/yuin/gopher-lua"
)

func TestWeztermRemoveFilePrefix(t *testing.T) {
	l, removeFilePrefix := loadWeztermHelpersLuaFunction(t, "remove_file_prefix")

	tests := []struct {
		input    string
		expected string
	}{
		{"file:///home/foo/bar", "~/bar"},
		{"file:///usr/local/bin", "/usr/local/bin"},
	}

	for _, test := range tests {
		t.Run(test.input, func(t *testing.T) {
			require.NoError(t, l.CallByParam(lua.P{
				Fn:      removeFilePrefix,
				NRet:    1,
				Protect: true,
			}, lua.LString(test.input), lua.LString("/home/foo")))

			ret := l.Get(-1)
			l.Pop(1)

			assert.Equal(t, test.expected, ret.String())
		})
	}
}

func TestWeztermUnescape(t *testing.T) {
	l, unescape := loadWeztermHelpersLuaFunction(t, "unescape")

	tests := []struct {
		input    string
		expected string
	}{
		{"~/bar%20baz", "~/bar baz"},
	}

	for _, test := range tests {
		t.Run(test.input, func(t *testing.T) {
			require.NoError(t, l.CallByParam(lua.P{
				Fn:      unescape,
				NRet:    1,
				Protect: true,
			}, lua.LString(test.input), lua.LString("/home/foo")))

			ret := l.Get(-1)
			l.Pop(1)

			assert.Equal(t, test.expected, ret.String())
		})
	}
}

func TestWeztermBasename(t *testing.T) {
	l, basename := loadWeztermHelpersLuaFunction(t, "basename")

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
		{`sudo FOO=var bash`, "bash"}, // that's the command being run
		{`FOO cat`, "FOO"},            // should output FOO, which is the command going to be run
		{`vi .config/stern/config.yaml`, "vi"},
		{``, ""},
	}

	for _, test := range tests {
		t.Run(test.input, func(t *testing.T) {
			require.NoError(t, l.CallByParam(lua.P{
				Fn:      basename,
				NRet:    1,
				Protect: true,
			}, lua.LString(test.input)))

			ret := l.Get(-1)
			l.Pop(1)

			assert.Equal(t, test.expected, ret.String())
		})
	}
}

func loadWeztermHelpersLuaFunction(t *testing.T, name string) (*lua.LState, lua.LValue) {
	l := lua.NewState()
	t.Cleanup(l.Close)
	require.NoError(t, l.DoFile(filepath.Join("..", "home", "private_dot_config", "wezterm", "helpers.lua")))

	return l, l.Get(-1).(*lua.LTable).RawGet(lua.LString(name))
}

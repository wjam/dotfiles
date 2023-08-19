package main

import (
	"os"
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

func TestWeztermSetAppearance(t *testing.T) {
	v := loadWeztermHelpersLuaFunction(t, "set_appearance")

	tests := []struct {
		name       string
		initial    string
		appearance string
		expected   string
		updated    bool
	}{
		{
			name:       "update-when-now-dark",
			initial:    "light",
			appearance: "Something Something Dark side",
			expected:   "dark",
			updated:    true,
		},
		{
			name:       "update-when-now-light",
			initial:    "dark",
			appearance: "The feather",
			expected:   "light",
			updated:    true,
		},
		{
			name:       "do-not-update-when-already-light",
			initial:    "light",
			appearance: "A light thing",
			expected:   "light",
			updated:    false,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			f := filepath.Join(t.TempDir(), "file.txt")

			require.NoError(t, os.WriteFile(f, []byte(test.initial), 0644))

			if !test.updated {
				require.NoError(t, os.Chmod(f, 0444))
				t.Cleanup(func() {
					assert.NoError(t, os.Chmod(f, 0644))
				})
			}

			v(identifiedFunc{
				name: "get_appearance",
				f:    luaFuncRetString(test.appearance),
			}, f)

			actual, err := os.ReadFile(f)
			require.NoError(t, err)

			assert.Equal(t, test.expected, string(actual))
		})
	}

}

func loadWeztermHelpersLuaFunction(t *testing.T, name string) func(...any) string {
	l := lua.NewState()
	t.Cleanup(l.Close)
	require.NoError(t, l.DoFile(filepath.Join("..", "home", "private_dot_config", "wezterm", "helpers.lua")))

	f := l.Get(-1).(*lua.LTable).RawGet(lua.LString(name))

	return func(args ...any) string {
		var lvArgs []lua.LValue
		for _, arg := range args {
			switch v := arg.(type) {
			case string:
				lvArgs = append(lvArgs, lua.LString(v))
			case identifiedFunc:
				t := l.NewTable()
				l.SetField(t, v.name, l.NewFunction(v.f))
				lvArgs = append(lvArgs, t)
			}
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

type identifiedFunc struct {
	name string
	f    lua.LGFunction
}

func luaFuncRetString(v string) lua.LGFunction {
	return func(l *lua.LState) int {
		l.Push(lua.LString(v))

		// The number of values we return to Lua
		return 1
	}
}

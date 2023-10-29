package main

import (
	"os"
	"path/filepath"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	lua "github.com/yuin/gopher-lua"
)

func TestWeztermSetPowerlineAppearance(t *testing.T) {
	v := loadWeztermHelpersLuaFunction[any](t, "set_powerline_appearance")

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

func TestWeztermSetBtopApperance(t *testing.T) {
	v := loadWeztermHelpersLuaFunction[any](t, "set_btop_appearance")

	tests := []struct {
		name       string
		initial    string
		appearance string
		expected   string
	}{
		{
			name:       "update-when-now-dark",
			initial:    "light.theme",
			appearance: "Something Something Dark side",
			expected:   "dark.theme",
		},
		{
			name:       "update-when-now-light",
			initial:    "dark.theme",
			appearance: "The feather",
			expected:   "light.theme",
		},
		{
			name:       "do-not-update-when-already-light",
			initial:    "light.theme",
			appearance: "A light thing",
			expected:   "light.theme",
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			dir := t.TempDir()
			current := filepath.Join(dir, "current.theme")
			light := "light.theme"
			dark := "dark.theme"

			require.NoError(t, os.Symlink(test.initial, current))

			v(identifiedFunc{
				name: "get_appearance",
				f:    luaFuncRetString(test.appearance),
			}, current, light, dark)

			actual, err := os.Readlink(current)
			require.NoError(t, err)

			assert.Equal(t, test.expected, string(actual))
		})
	}
}

func TestWeztermSetPowerlineAppearance_GuiNotReadyYet(t *testing.T) {
	v := loadWeztermHelpersLuaFunction[any](t, "set_appearance")

	f := filepath.Join(t.TempDir(), "file.txt")

	v(nil, f)

	assert.NoFileExists(t, f)
}

func TestFormatWindowTitle(t *testing.T) {
	v := loadWeztermHelpersLuaFunction[string](t, "format_window_title")

	tests := []struct {
		name  string
		index int
		count int
		prog  any
		ssh   bool
		user  string
		host  string
		home  string
		cwd   string

		expected string
	}{
		{
			name:     "output-program-not-on-ssh",
			index:    0,
			count:    2,
			prog:     "/usr/bin/vi foo.txt",
			ssh:      false,
			user:     "me",
			host:     "example.test",
			home:     "/home/me",
			cwd:      "file:///home/me/foo",
			expected: "[1/2] /usr/bin/vi foo.txt",
		},
		{
			name:     "output-program-on-ssh",
			index:    0,
			count:    2,
			prog:     "/usr/bin/vi foo.txt",
			ssh:      true,
			user:     "me",
			host:     "example.test",
			home:     "/home/me",
			cwd:      "file:///home/me/foo",
			expected: "[1/2] me@example.test /usr/bin/vi foo.txt",
		},
		{
			name:     "output-dir-not-on-ssh",
			index:    0,
			count:    1,
			prog:     nil,
			ssh:      false,
			user:     "me",
			host:     "example.test",
			home:     "/home/me",
			cwd:      "file:///home/me/foo",
			expected: "~/foo",
		},
		{
			name:     "output-dir-outside-home-not-on-ssh",
			index:    0,
			count:    1,
			prog:     nil,
			ssh:      false,
			user:     "me",
			host:     "example.test",
			home:     "/home/me",
			cwd:      "file:///usr/local/bin",
			expected: "/usr/local/bin",
		},
		{
			name:     "output-dir-on-ssh",
			index:    0,
			count:    2,
			prog:     nil,
			ssh:      true,
			user:     "me",
			host:     "example.test",
			home:     "/home/me",
			cwd:      "file:///home/me/foo",
			expected: "[1/2] me@example.test:~/foo",
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			tab := map[string]any{
				"tab_index": test.index,
				"active_pane": map[string]any{
					"current_working_dir": test.cwd,
				},
			}
			pane := map[string]any{
				"user_vars": map[string]any{
					"WEZTERM_PROG": test.prog,
					"WEZTERM_SSH":  strconv.FormatBool(test.ssh),
					"WEZTERM_USER": test.user,
					"WEZTERM_HOST": test.host,
					"WEZTERM_HOME": test.home,
				},
			}
			var tabs []any
			for i := 0; i < test.count; i++ {
				tabs = append(tabs, i)
			}
			actual := v(tab, pane, tabs, "panes", "config")

			assert.Equal(t, test.expected, actual)
		})
	}
}

func TestFormatTabTitle(t *testing.T) {
	v := loadWeztermHelpersLuaFunction[[]any](t, "format_tab_title")

	tests := []struct {
		name   string
		index  int
		prog   any
		unseen bool
		ssh    bool
		user   string
		host   string
		home   string
		cwd    string

		expected []any
	}{
		{
			name:   "program-without-ssh",
			index:  1,
			prog:   "sleep",
			unseen: true,
			ssh:    false,
			user:   "me",
			host:   "example.test",
			home:   "/home/me",
			cwd:    "file:///home/me/foo",
			expected: []any{
				map[string]any{"Background": map[string]any{"Color": "blue"}},
				map[string]any{"Text": "  *2: sleep "},
			},
		},
		{
			name:   "full-program-path-truncated-to-binary",
			index:  1,
			prog:   "/usr/bin/sleep",
			unseen: false,
			ssh:    false,
			user:   "me",
			host:   "example.test",
			home:   "/home/me",
			cwd:    "file:///home/me/foo",
			expected: []any{
				map[string]any{"Text": " 2: sleep "},
			},
		},
		{
			name:   "sudo-truncated-from-binary",
			index:  1,
			prog:   "sudo /usr/bin/cat",
			unseen: false,
			ssh:    false,
			user:   "me",
			host:   "example.test",
			home:   "/home/me",
			cwd:    "file:///home/me/foo",
			expected: []any{
				map[string]any{"Text": " 2: cat "},
			},
		},
		{
			name:   "env-var-truncated-from-binary",
			index:  1,
			prog:   "FOO=var cat",
			unseen: false,
			ssh:    false,
			user:   "me",
			host:   "example.test",
			home:   "/home/me",
			cwd:    "file:///home/me/foo",
			expected: []any{
				map[string]any{"Text": " 2: cat "},
			},
		},
		{
			name:   "multiple-env-var-truncated-from-binary",
			index:  1,
			prog:   "FOO=var BAR=var cat",
			unseen: false,
			ssh:    false,
			user:   "me",
			host:   "example.test",
			home:   "/home/me",
			cwd:    "file:///home/me/foo",
			expected: []any{
				map[string]any{"Text": " 2: cat "},
			},
		},
		{
			name:   "sudo-and-env-var-truncated-from-binary",
			index:  1,
			prog:   "sudo FOO=var cat",
			unseen: false,
			ssh:    false,
			user:   "me",
			host:   "example.test",
			home:   "/home/me",
			cwd:    "file:///home/me/foo",
			expected: []any{
				map[string]any{"Text": " 2: cat "},
			},
		},
		{
			name:   "sudo-env-var-and-bash-truncated-from-binary",
			index:  1,
			prog:   "sudo FOO=var bash cat",
			unseen: false,
			ssh:    false,
			user:   "me",
			host:   "example.test",
			home:   "/home/me",
			cwd:    "file:///home/me/foo",
			expected: []any{
				map[string]any{"Text": " 2: cat "},
			},
		},
		{
			name:   "bash-not-truncated-when-command-run",
			index:  1,
			prog:   "sudo FOO=var bash",
			unseen: false,
			ssh:    false,
			user:   "me",
			host:   "example.test",
			home:   "/home/me",
			cwd:    "file:///home/me/foo",
			expected: []any{
				map[string]any{"Text": " 2: bash "},
			},
		},
		{
			name:   "upper-case-is-not-env-var",
			index:  1,
			prog:   "FOO cat",
			unseen: false,
			ssh:    false,
			user:   "me",
			host:   "example.test",
			home:   "/home/me",
			cwd:    "file:///home/me/foo",
			expected: []any{
				map[string]any{"Text": " 2: FOO "},
			},
		},
		{
			name:   "truncate-args",
			index:  1,
			prog:   "vi .config/stern/config.yaml",
			unseen: false,
			ssh:    false,
			user:   "me",
			host:   "example.test",
			home:   "/home/me",
			cwd:    "file:///home/me/foo",
			expected: []any{
				map[string]any{"Text": " 2: vi "},
			},
		},
		{
			name:   "program-with-ssh",
			index:  1,
			prog:   "/usr/bin/vi foo.txt",
			unseen: false,
			ssh:    true,
			user:   "me",
			host:   "example.test",
			home:   "/home/me",
			cwd:    "file:///home/me/foo",
			expected: []any{
				map[string]any{"Text": " 2: me@example.test vi "},
			},
		},
		{
			name:   "no-program-without-ssh",
			index:  1,
			prog:   nil,
			unseen: false,
			ssh:    false,
			user:   "me",
			host:   "example.test",
			home:   "/home/me",
			cwd:    "file:///home/me/foo%20bar",
			expected: []any{
				map[string]any{"Text": " 2: ~/foo bar "},
			},
		},
		{
			name:   "no-program-with-ssh",
			index:  1,
			prog:   "",
			unseen: false,
			ssh:    true,
			user:   "me",
			host:   "example.test",
			home:   "/home/me",
			cwd:    "file:///usr/local/bin",
			expected: []any{
				map[string]any{"Text": " 2: me@example.test:/usr/local/bin "},
			},
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			tab := map[string]any{
				"tab_index": test.index,
				"active_pane": map[string]any{
					"current_working_dir": test.cwd,
					"has_unseen_output":   test.unseen,
					"user_vars": map[string]any{
						"WEZTERM_PROG": test.prog,
						"WEZTERM_SSH":  strconv.FormatBool(test.ssh),
						"WEZTERM_USER": test.user,
						"WEZTERM_HOST": test.host,
						"WEZTERM_HOME": test.home,
					},
				},
			}

			actual := v(tab, "tabs", "panes", "config", "hover", "max_width")
			assert.Equal(t, test.expected, actual)
		})
	}

}

func loadWeztermHelpersLuaFunction[V any](t *testing.T, name string) func(...any) V {
	l := lua.NewState()
	t.Cleanup(l.Close)
	require.NoError(t, l.DoFile(filepath.Join("..", "home", "private_dot_config", "wezterm", "helpers.lua")))

	f := l.Get(-1).(*lua.LTable).RawGet(lua.LString(name))

	return func(args ...any) V {
		var lvArgs []lua.LValue
		for _, arg := range args {
			lvArgs = append(lvArgs, convertToLua(t, l, arg))
		}

		require.NoError(t, l.CallByParam(lua.P{
			Fn:      f,
			NRet:    1,
			Protect: true,
		}, lvArgs...))

		ret := l.Get(-1)
		l.Pop(1)

		v := convertFromLua(t, ret)

		if v == nil {
			var empty V
			return empty
		}

		return v.(V)
	}
}

func convertToLua(t *testing.T, l *lua.LState, arg any) lua.LValue {
	if arg == nil {
		return lua.LNil
	}
	switch v := arg.(type) {
	case string:
		return lua.LString(v)
	case int:
		return lua.LNumber(v)
	case bool:
		return lua.LBool(v)
	case identifiedFunc:
		t := l.NewTable()
		l.SetField(t, v.name, l.NewFunction(v.f))
		return t
	case map[string]any:
		table := l.NewTable()
		for key, value := range v {
			l.SetField(table, key, convertToLua(t, l, value))
		}
		return table
	case []any:
		table := l.NewTable()
		for _, value := range v {
			table.Append(convertToLua(t, l, value))
		}
		return table
	default:
		t.Fatalf("unsupported type %T", v)
		return nil
	}
}

func convertFromLua(t *testing.T, luaV lua.LValue) any {
	switch v := luaV.(type) {
	case lua.LString:
		return v.String()
	case *lua.LTable:
		if length := v.Len(); length != 0 {
			// it's an array
			var ret []any
			for i := 0; i < length; i++ {
				ret = append(ret, convertFromLua(t, v.RawGetInt(i+1)))
			}
			return ret
		}

		ret := map[string]any{}
		v.ForEach(func(key lua.LValue, value lua.LValue) {
			ret[key.String()] = convertFromLua(t, value)
		})
		return ret
	case *lua.LNilType:
		return nil
	default:
		t.Fatalf("unknown type %T", v)
		return nil
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

//go:build linux

package main

import (
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

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

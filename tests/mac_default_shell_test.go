//go:build darwin

package main

import (
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/stretchr/testify/require"
)

func getDefaultShell(t *testing.T) string {
	home, err := os.UserHomeDir()
	require.NoError(t, err)
	userShell := shell.RunCommandAndGetOutput(t, shell.Command{
		Command: "dscl",
		Args:    []string{".", "-read", home, "UserShell"},
		Logger:  logger.New(testLogger{}),
	})
	return strings.TrimSpace(strings.Split(userShell, ":")[1])
}

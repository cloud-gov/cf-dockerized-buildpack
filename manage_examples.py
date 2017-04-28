import os
import sys
import subprocess
import re
import time
import urllib2
import urlparse
import argparse

# The directory this script is located in.
MY_DIR = os.path.abspath(os.path.dirname(__file__))

# Directory containing examples.
EXAMPLES_DIR = os.path.join(MY_DIR, 'examples')

# Port that all examples listen on.
PORT = 8080

# Regular expression that all example homepages match.
INDEX_RE = re.compile('hello world', flags=re.IGNORECASE)

# Maximum numer of times we'll try to ping the example's homepage.
MAX_ATTEMPTS = 5

# Seconds between each homepage ping attempt.
SECONDS_BTWN_ATTEMPTS = 1

class ExampleApp(object):
    """
    Encapsulates an example app written in any language.
    """

    def __init__(self, name):  # type: (str) -> None
        self.name = name
        self.path = os.path.join(EXAMPLES_DIR, name)

    @classmethod
    def get_all_names(cls):  # type: () -> List[str]
        """
        Gets the names of all available examples.
        """

        return [d for d in os.listdir(EXAMPLES_DIR)
                if os.path.isdir(os.path.join(EXAMPLES_DIR, d))
                and not d.startswith('.')]

    @classmethod
    def get_all(cls):  # type: () -> List[ExampleApp]
        """
        Returns a list of all available examples.
        """

        return [cls(name) for name in cls.get_all_names()]

    @classmethod
    def from_cmdline_arg(cls, s):  # type (str) -> ExampleApp
        """
        Given an example name, returns a corresponding ExampleApp
        instance or raises a helpful error with suggestions.
        """

        example = [e for e in cls.get_all() if e.name == s]
        if not example:
            raise argparse.ArgumentTypeError(
                'invalid example, "{}" is not one of: {}'.format(
                    s,
                    ', '.join(cls.get_all_names())
                )
            )
        return example[0]

    def cleanup(self):  # type: () -> None
        """
        Clean up Docker resources used by an example.
        """

        subprocess.check_call(['docker-compose', 'down', '-v'],
                              cwd=self.path)

    def test(self):  # type: () -> None
        """
        Build and test the example.
        """

        subprocess.check_call(['docker-compose', 'build'], cwd=self.path)
        popen = subprocess.Popen(['docker-compose', 'up'], cwd=self.path)
        name = '{} server'.format(self.name)
        attempt = 1
        try:
            while True:
                print('checking if {} works...'.format(name))
                if popen.returncode is not None:
                    raise Exception('{} died'.format(name))
                if is_server_working():
                    print('{} server works!'.format(name))
                    break
                print('{} server not working, trying again.'.format(name))
                time.sleep(SECONDS_BTWN_ATTEMPTS)
                attempt += 1
                if attempt > MAX_ATTEMPTS:
                    raise Exception('{} failed after {} attempts'.format(
                        name,
                        MAX_ATTEMPTS
                    ))
        finally:
            print("shutting down {}...".format(name))
            popen.kill()


def get_server_url():  # type: () -> str
    """
    Get the server URL for any example (they all use the same port).

    Also works if the system is using docker-machine.
    """

    server = '127.0.0.1'
    if 'DOCKER_HOST' in os.environ:
        server = urlparse.urlparse(os.environ['DOCKER_HOST']).hostname
    return 'http://{}:{}/'.format(server, PORT)


def is_server_working():  # type: () -> bool
    """
    Attempts to ping the 
    """

    url = get_server_url()
    print("Attempting to retrieve {}...".format(url))
    try:
        f = urllib2.urlopen(url)
        return bool(INDEX_RE.search(f.read()))
    except urllib2.URLError:
        return False


def selftest(args):  # type: (argparse.Namespace) -> None
    """
    Self-test this program (requires mypy).
    """

    subprocess.check_call(
        'mypy --py2 --strict-optional -v {}'.format(__file__),
        shell=True
    )


def cleanup(args):  # type: (argparse.Namespace) -> None
    """
    Clean up Docker resources used by example(s).
    """

    for e in args.example:
        e.cleanup()


def test(args):  # type: (argparse.Namespace) -> None
    """
    Build and test example(s).
    """

    for e in args.example:
        e.test()


def add_example_arg(parser):  # type: (argparse.ArgumentParser) -> None
    """
    Add [example [example ...]] to the given parser; if no example
    is provided, we default to all examples. Examples are converted
    to valid ExampleApp instances.
    """

    parser.add_argument(
        'example',
        help=(
            'One of: {}. '.format(', '.join(ExampleApp.get_all_names())) +
            'If absent, defaults to all examples.'
        ),
        nargs='*', default=ExampleApp.get_all(),
        type=ExampleApp.from_cmdline_arg
    )


def main():  # type: () -> None
    """
    Run the CLI.
    """

    parser = argparse.ArgumentParser(
        description='Manage cf-dockerized-buildpack examples.'
    )
    subs = parser.add_subparsers(help='sub-command help')

    p_selftest = subs.add_parser('selftest', help=selftest.__doc__)
    p_selftest.set_defaults(func=selftest)

    p_test = subs.add_parser('test', help=test.__doc__)
    add_example_arg(p_test)
    p_test.set_defaults(func=test)

    p_cleanup = subs.add_parser('cleanup', help=cleanup.__doc__)
    add_example_arg(p_cleanup)
    p_cleanup.set_defaults(func=cleanup)

    args = parser.parse_args()
    args.func(args)


if __name__ == '__main__':
    main()

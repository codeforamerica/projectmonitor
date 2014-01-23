# Contribute.md
This is the CONTRIBUTE.md for our project. Great to have you here. Have a look at our README.md if you're unfamiliar with Project Monitor.

## Resources
Owner: [Erica Kwan](mailto:erica@codeforamerica.org)

## A high level introduction to Project Monitor
There are two distinct layers to Project Monitor:

1. the front end which polls the back end for updates and
2. the back end which polls CI builds and receives webhook updates.

The back end receives updates through a REST/json interface, or it uses delayed_job to poll CI instances.

## Gotchas (when things do not appear to be working as expected, try these...)
* Are the workers running? Have you checked the worker log in log/delayed_job.log?
* You can run `rake projectmonitor:fetch_statuses` to force update the builds.

## Bug triage
If you encounter any bugs, feel free to file an issue in Github or contact Erica: [Erica Kwan](mailto:erica@codeforamerica.org).

## A final word
Please consider this a living document. When you've finished your work please take a minute to think of the developers who will follow in your footsteps. Is there anything missing from this document that you'd wished you'd known before you started coding?

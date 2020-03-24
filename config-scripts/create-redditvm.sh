#!/bin/bash

gcloud compute instances create reddit-app1 \
--boot-disk-size=10GB \
--image=reddit-full-1585048298 \
--machine-type=f1-micro \
--tags puma-server \
--zone=us-central1-f \
--preemptible \

#!/usr/bin/env python
import sys
from twython import Twython
CONSUMER_KEY = 'bbCONSKEYbb'
CONSUMER_SECRET = 'bbCONSSECbb'
ACCESS_KEY = 'bbACCTOKbb'
ACCESS_SECRET = 'bbACCTOKSECbb'

api = Twython(CONSUMER_KEY,CONSUMER_SECRET,ACCESS_KEY,ACCESS_SECRET) 

photo = open(sys.argv[2], 'rb')

# api.update_status(status=sys.argv[1])

api.update_status_with_media(status=sys.argv[1], media=photo)

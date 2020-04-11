#!/usr/bin/env python
import sys
from twython import Twython
CONSUMER_KEY = 'bbCONSKEYbb'
CONSUMER_SECRET = 'bbCONSSECbb'
ACCESS_KEY = 'bbACCTOKbb'
ACCESS_SECRET = 'bbACCTOKSECbb'

api = Twython(CONSUMER_KEY,CONSUMER_SECRET,ACCESS_KEY,ACCESS_SECRET) 

api.update_status(status=sys.argv[1])

# photo = open('/path/to/file/image.jpg', 'rb')
# twitter.update_status_with_media(status='Checkout this cool image!', media=photo)

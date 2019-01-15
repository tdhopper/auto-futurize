name = raw_input("What is your name?\n")

for k, v in d.iteritems():
    assert isinstance(v, basestring)


class MyClass(object):
    def __unicode__(self):
        return u"My object"

    def __str__(self):
        return unicode(self).encode("utf-8")

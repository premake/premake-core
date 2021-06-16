**Values returned from `fetch()` should be considered immutable!**

I don't have a way to enforce that (yet), so you'll just have to be on your best behavior. If you change a value returned from this method, you may be changing it for all future calls as well. Make copies before making changes! (We don't want to be making copies here because that would be a big
performance hit, and most times it isn't needed.)

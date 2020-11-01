
# FIXME: -this needs a better home!
def format opts={}
  opts = { format: opts.to_sym } if [Symbol, String].member? opts.class
  Card::Format.new self, opts
end

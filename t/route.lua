local route = require 'lj.web.route'

local function t(path, rpath, rnames)
    local p, n = route.compile_patt(nil, path)
    print(path, p, rpath)
    if p ~= rpath then
        return false
    end

    for name, idx in pairs(rnames) do
        print(path, name, idx, n[name])

        if idx ~= n[name] then
            return false
        end
    end

    return true
end

assert(t('/', '^/$', {}), 'test 1')
assert(t('/abc', '^/abc$', {}), 'test 2')
assert(t('/:abc', '^/([^/]+)$', {abc=1}), 'test :')
assert(t('/<ab>c', '^/([^/]+)c$', {ab=1}), 'test <>')
assert(t('/:ab/:c', '^/([^/]+)/([^/]+)$', {ab=1, c=2}), 'test multi :')

assert(t('/a::b:c', '^/a:b([^/]+)$', {c=1}), 'escape :')
assert(t('/:<ab>c', '^/<ab>c$', {}), 'escape <')


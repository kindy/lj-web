-- jQuery-like selector for nginx conf

local T = require 'luat'

local class, parent_class = T.class, T.class.parent_class

Node = class('Node', {
    name = nil;
    args = nil;

    new = function(self, name, args)
        local obj = {}

        obj.name = name
        obj.args = args and T.list(args):slice() or nil

        return obj
    end;

    to_conf = function(self, ind, close)
        return (string.rep(' ', ind or 0)) .. self.name .. ' ' .. self.args.join(' ') .. (close and ';' or '')
    end;

    parse = function(self, str)
        local name, args = ...

        return self:new(name, args)
    end;

    get_parent = function(self)
    end;
    get_prev = function(self)
    end;
    get_next = function(self)
    end;
})

BlockNode = class('BlockNode', Node, {
    _conf_show_node_name = true;

    new = function(self, name, args, nodes)
        local obj = parent_class(self).new(self, name, args)

        obj.nodes = nodes.slice()

        return obj
    end;

    parse = function(self, str)
        local name, args, nodes = ...

        return self:new(name, args, nodes)
    end;

    to_conf = function(self, ind)
        local str = T.list {}
        if self._conf_show_node_name then
            str:append(parent_class(self).to_conf(self, ind, false) .. ' {')
        end

        for _, node in ipairs(self.nodes) do
            str:append(node:to_conf(ind + 1, true))
        end

        if self._conf_show_node_name then
            str:append '}'
        end

        return str:join '\n'
    end;

    get_children = function(self)
    end;
})

RootNode = class('RootNode', BlockNode, {
    _conf_show_node_name = false;

    new = function(self, nodes)
        local obj = parent_class(self).new(self, '_root_', nil, nodes)

        return obj
    end;

    parse = function(self, str)
        nodes = ...
        return self:new(nodes)
    end;
})

NodeSet = clsss('NodeSet', {
    q = function(self, selector)
    end;
})


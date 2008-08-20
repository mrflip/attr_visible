require 'attr_visible'
ActiveRecord::Base.class_eval { include AttrVisible }

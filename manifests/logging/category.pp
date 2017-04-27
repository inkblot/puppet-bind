# ex: syntax=puppet si ts=4 sw=4 et

define bind::logging::category (
    $channels
) {
    concat::fragment { "bind-logging-category-${name}":
        order   => "60-${name}",
        target  => "${::bind::confdir}/logging.conf",
        content => inline_template("\tcategory <%= @name %> {\n<% Array(@channels).each { |c| %>\t\t<%= c %>;\n<% } %>\t};\n"),
    }
}

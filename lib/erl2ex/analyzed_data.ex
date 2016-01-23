
defmodule Erl2ex.AnalyzedFunc do
  @moduledoc false

  defstruct func_name: {},
            is_exported: false,  # At least one arity is exported
            arities: %{}         # Map of arity to exported flag

end


defmodule Erl2ex.AnalyzedImport do
  @moduledoc false

  defstruct arities: %{}   # Map of arities to modules

end


defmodule Erl2ex.AnalyzedType do
  @moduledoc false

  defstruct arities: %{}   # Map of arity to exported flag

end


defmodule Erl2ex.AnalyzedMacro do
  @moduledoc false

  defstruct const_name: nil,
            func_name: nil,
            define_tracker: nil,
            requires_init: nil,
            has_func_style_call: false,
            is_redefined: MapSet.new

end


defmodule Erl2ex.AnalyzedRecord do
  @moduledoc false

  defstruct func_name: nil,
            data_name: nil,
            fields: []

end


defmodule Erl2ex.AnalyzedModule do
  @moduledoc false

  defstruct erl_module: nil,
            imports: %{},
            funcs: %{},
            types: %{},
            macros: %{},
            records: %{},
            used_func_names: MapSet.new,
            used_attr_names: MapSet.new,
            macro_dispatcher: nil,
            func_renamer: nil,
            record_size_macro: nil,
            record_index_macro: nil,
            specs: %{}

end

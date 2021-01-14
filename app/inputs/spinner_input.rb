class SpinnerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    input = super(wrapper_options)
    minus_button + input + plus_button
  end

  private

  def minus_button
    template.content_tag :i, '', class: 'fa fa-minus-circle minus_button'
  end

  def plus_button
    template.content_tag :i, '', class: 'fa fa-plus-circle plus_button'
  end
end
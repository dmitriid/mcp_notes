defmodule McpNotesWeb.Components.MishkaComponents do
  @moduledoc """
  Convenience module that imports all Mishka UI components.
  
  Use this module to import all available UI components into your views or components.
  """
  
  defmacro __using__(_) do
    quote do
      alias McpNotesWeb.Components
      
      # Import all components with shorter syntax
      import Components.{
        Accordion, Alert, Avatar, Badge, Banner, Blockquote, Breadcrumb, Button,
        Card, Carousel, Chat, CheckboxCard, CheckboxField, Clipboard, ColorField,
        Combobox, DateTimeField, DeviceMockup, Divider, Drawer, Dropdown,
        EmailField, Fieldset, FileField, Footer, FormWrapper, Gallery,
        Icon, Image, Indicator, InputField, Jumbotron, Keyboard, Layout, List,
        MegaMenu, Menu, Modal, NativeSelect, Navbar, NumberField, Overlay,
        Pagination, PasswordField, Popover, Progress, RadioCard, RadioField,
        RangeField, Rating, ScrollArea, SearchField, Sidebar, Skeleton,
        SpeedDial, Spinner, Stepper, Table, TableContent, Tabs, TelField,
        TextField, TextareaField, Timeline, Toast, ToggleField, Tooltip,
        Typography, UrlField, Video
      }
    end
  end
end
defmodule Simhash do
  @moduledoc """
  Provides simhash.

  ## Examples

      iex> Simhash.similarity("Universal Avenue", "Universe Avenue")
      0.71875

      iex> Simhash.similarity("hocus pocus", "pocus hocus")
      0.8125

      iex> Simhash.similarity("Sankt Eriksgatan 1", "S:t Eriksgatan 1")
      0.8125

      iex> Simhash.similarity("Purple flowers", "Green grass")
      0.5625

      iex> Simhash.similarity("Peanut butter", "Strawberry cocktail")
      0.4375

  By default trigrams (N-gram of size 3) are used as language features, but you can
  set a different N-gram size:

      iex> Simhash.similarity("hocus pocus", "pocus hocus", 1)
      1.0

      iex> Simhash.similarity("Sankt Eriksgatan 1", "S:t Eriksgatan 1", 6)
      0.859375

      iex> Simhash.similarity("Purple flowers", "Green grass", 6)
      0.546875

  Algorithm description: http://matpalm.com/resemblance/simhash/
  """
  use Bitwise

  @doc """
  Calculates the similarity between the left and right string, using Simhash.
  """
  def similarity(left, right, n \\ 3) do
    hash_similarity(hash(left, n), hash(right, n))
  end

  @doc """
  Generates the hash for the given subject. The feature hashes are N-grams, where
  N is given by the parameter n.
  """
  def hash(subject, n \\ 3) do
    subject
    |> feature_hashes(n)
    |> vector_addition
    |> normalize_bits
  end

  @doc """
  Returns list of lists of bits of 64bit Siphashes for each shingle
  """
  def feature_hashes(subject, n) do
    subject
    |> n_grams(n)
    |> Enum.map(&siphash/1)
    |> Enum.map(&to_list/1)
  end

  @doc """
  Calculate the similarity between the left and right hash, using Simhash.
  """
  def hash_similarity(left, right) do
    1 - hamming_distance(left, right) / 64
  end

  @doc """
  Hamming distance between the left and right hash, given as lists of bits.

      iex> Simhash.hamming_distance([1, 1, 0, 1, 0], [0, 1, 1, 1, 0])
      2

  """
  def hamming_distance(left, right, acc \\ 0)

  def hamming_distance([same | tl_left], [same | tl_right], acc) do
    hamming_distance(tl_left, tl_right, acc)
  end

  def hamming_distance([_ | tl_left], [_ | tl_right], acc) do
    hamming_distance(tl_left, tl_right, acc + 1)
  end

  def hamming_distance([], [], acc), do: acc

  @doc """
  Reduce list of lists to list of integers, following vector addition.

  Example:

      iex> Simhash.vector_addition([[1, 3, 2, 1], [0, 1, -1, 2], [2, 0, 0, 0]])
      [3, 4, 1, 3]

  """
  def vector_addition(lists) do
    lists
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.sum/1)
  end

  defp to_list(<<1::size(1), data::bitstring>>), do: [1 | to_list(data)]
  defp to_list(<<0::size(1), data::bitstring>>), do: [-1 | to_list(data)]
  defp to_list(<<>>), do: []

  defp normalize_bits([head | tail]) when head > 0, do: [1 | normalize_bits(tail)]
  defp normalize_bits([_head | tail]), do: [0 | normalize_bits(tail)]
  defp normalize_bits([]), do: []

  @doc """
  Returns N-grams of input str.

      iex> Simhash.n_grams("Universal")
      ["Uni", "niv", "ive", "ver", "ers", "rsa", "sal"]

  [More about N-gram](https://en.wikipedia.org/wiki/N-gram#Applications_and_considerations)
  """
  def n_grams(str, n \\ 3) do
    str
    |> String.graphemes()
    |> do_n_grams(n)
  end

  defp do_n_grams(graphemes, n) do
    n_gram = graphemes |> Enum.take(n)

    case length(n_gram) == n do
      true ->
        [n_gram |> :binary.list_to_bin | do_n_grams(tl(graphemes), n)]
      false ->
        []
    end
  end

  @doc """
  Returns the 64bit Siphash for input str as bitstring.

      iex> Simhash.siphash("abc")
      <<249, 236, 145, 130, 66, 18, 3, 247>>

      iex> byte_size(Simhash.siphash("abc"))
      8

  """
  def siphash(str), do: SipHash.hash!("0123456789ABCDEF", str) |> :binary.encode_unsigned()
end
